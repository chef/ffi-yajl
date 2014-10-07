#include <ruby.h>
#include <yajl/yajl_gen.h>

static VALUE mFFI_Yajl, mExt, mEncoder, mEncoder2, cEncodeError;
static VALUE cDate, cTime, cDateTime;
static VALUE cYajl_Gen;

/* FIXME: the json gem does a whole bunch of indirection around monkeypatching...  not sure if we need to as well... */

#define CHECK_STATUS(call) \
      if ((status = (call)) != yajl_gen_status_ok) { rb_funcall(mEncoder2, rb_intern("raise_error_for_status"), 1, INT2FIX(status)); }

static VALUE mEncoder_do_yajl_encode(VALUE self, VALUE obj, VALUE yajl_gen_opts, VALUE json_opts) {
  ID sym_ffi_yajl = rb_intern("ffi_yajl");
  VALUE sym_yajl_gen_beautify = ID2SYM(rb_intern("yajl_gen_beautify"));
  VALUE sym_yajl_gen_validate_utf8 = ID2SYM(rb_intern("yajl_gen_validate_utf8"));
  VALUE sym_yajl_gen_indent_string = ID2SYM(rb_intern("yajl_gen_indent_string"));
  yajl_gen yajl_gen;
  const unsigned char *buf;
  size_t len;
  VALUE state;
  VALUE ret;
  VALUE indent_string;
  VALUE rb_yajl_gen;

  yajl_gen = yajl_gen_alloc(NULL);

  if ( rb_hash_aref(yajl_gen_opts, sym_yajl_gen_beautify) == Qtrue ) {
    yajl_gen_config(yajl_gen, yajl_gen_beautify, 1);
  }
  if ( rb_hash_aref(yajl_gen_opts, sym_yajl_gen_validate_utf8) == Qtrue ) {
    yajl_gen_config(yajl_gen, yajl_gen_validate_utf8, 1);
  }

  indent_string = rb_hash_aref(yajl_gen_opts, sym_yajl_gen_indent_string);
  if (indent_string != Qnil) {
    yajl_gen_config(yajl_gen, yajl_gen_indent_string, RSTRING_PTR(indent_string));
  } else {
    yajl_gen_config(yajl_gen, yajl_gen_indent_string, " ");
  }

  state = rb_hash_new();

  rb_hash_aset(state, rb_str_new2("processing_key"), Qfalse);

  rb_hash_aset(state, rb_str_new2("json_opts"), json_opts);

  rb_yajl_gen = Data_Wrap_Struct(cYajl_Gen, NULL, NULL, yajl_gen);

  rb_funcall(obj, sym_ffi_yajl, 2, rb_yajl_gen, state);

  yajl_gen_get_buf(yajl_gen, &buf, &len);

  ret = rb_str_new2((char *)buf);

  yajl_gen_free(yajl_gen);

  return ret;
}

int rb_cHash_ffi_yajl_callback(VALUE key, VALUE val, VALUE extra) {
  ID sym_ffi_yajl = rb_intern("ffi_yajl");
  VALUE state = rb_hash_aref(extra, rb_str_new2("state"));
  VALUE rb_yajl_gen = rb_hash_aref(extra, rb_str_new2("yajl_gen"));

  rb_hash_aset(state, rb_str_new2("processing_key"), Qtrue);
  rb_funcall(key, sym_ffi_yajl, 2, rb_yajl_gen, state);
  rb_hash_aset(state, rb_str_new2("processing_key"), Qfalse);

  rb_funcall(val, sym_ffi_yajl, 2, rb_yajl_gen, state);

  return 0;
}

static VALUE rb_cHash_ffi_yajl(VALUE self, VALUE rb_yajl_gen, VALUE state) {
  yajl_gen_status status;
  VALUE extra;
  struct yajl_gen_t *yajl_gen;
  Data_Get_Struct(rb_yajl_gen, struct yajl_gen_t, yajl_gen);

  extra = rb_hash_new();  /* FIXME: reduce garbage */

  rb_hash_aset(extra, rb_str_new2("yajl_gen"), rb_yajl_gen);

  rb_hash_aset(extra, rb_str_new2("state"), state);

  CHECK_STATUS(
    yajl_gen_map_open(yajl_gen)
  );
  rb_hash_foreach(self, rb_cHash_ffi_yajl_callback, extra);
  CHECK_STATUS(
    yajl_gen_map_close(yajl_gen)
  );

  return Qnil;
}

static VALUE rb_cArray_ffi_yajl(VALUE self, VALUE rb_yajl_gen, VALUE state) {
  yajl_gen_status status;
  ID sym_ffi_yajl = rb_intern("ffi_yajl");
  long i;
  VALUE val;
  struct yajl_gen_t *yajl_gen;
  Data_Get_Struct(rb_yajl_gen, struct yajl_gen_t, yajl_gen);

  CHECK_STATUS(
    yajl_gen_array_open(yajl_gen)
  );
  for(i=0; i<RARRAY_LEN(self); i++) {
    val = rb_ary_entry(self, i);
    rb_funcall(val, sym_ffi_yajl, 2, rb_yajl_gen, state);
  }
  CHECK_STATUS(
    yajl_gen_array_close(yajl_gen)
  );

  return Qnil;
}

static VALUE rb_cNilClass_ffi_yajl(VALUE self, VALUE rb_yajl_gen, VALUE state) {
  yajl_gen_status status;
  struct yajl_gen_t *yajl_gen;
  Data_Get_Struct(rb_yajl_gen, struct yajl_gen_t, yajl_gen);
  CHECK_STATUS(
    yajl_gen_null(yajl_gen)
  );
  return Qnil;
}

static VALUE rb_cTrueClass_ffi_yajl(VALUE self, VALUE rb_yajl_gen, VALUE state) {
  yajl_gen_status status;
  struct yajl_gen_t *yajl_gen;
  Data_Get_Struct(rb_yajl_gen, struct yajl_gen_t, yajl_gen);
  CHECK_STATUS(
    yajl_gen_bool(yajl_gen, 1)
  );
  return Qnil;
}

static VALUE rb_cFalseClass_ffi_yajl(VALUE self, VALUE rb_yajl_gen, VALUE state) {
  yajl_gen_status status;
  struct yajl_gen_t *yajl_gen;
  Data_Get_Struct(rb_yajl_gen, struct yajl_gen_t, yajl_gen);
  CHECK_STATUS(
    yajl_gen_bool(yajl_gen, 0)
  );
  return Qnil;
}

static VALUE rb_cFixnum_ffi_yajl(VALUE self, VALUE rb_yajl_gen, VALUE state) {
  yajl_gen_status status;
  ID sym_to_s = rb_intern("to_s");
  VALUE str = rb_funcall(self, sym_to_s, 0);
  char *cptr = RSTRING_PTR(str);
  int len = RSTRING_LEN(str);
  struct yajl_gen_t *yajl_gen;
  Data_Get_Struct(rb_yajl_gen, struct yajl_gen_t, yajl_gen);

  if (memcmp(cptr, "NaN", 3) == 0 || memcmp(cptr, "Infinity", 8) == 0 || memcmp(cptr, "-Infinity", 9) == 0) {
    rb_raise(cEncodeError, "'%s' is an invalid number", cptr);
  }
  if ( rb_hash_aref(state, rb_str_new2("processing_key")) == Qtrue ) {
    CHECK_STATUS(
      yajl_gen_string(yajl_gen, (unsigned char *)cptr, len)
    );
  } else {
    CHECK_STATUS(
      yajl_gen_number(yajl_gen, cptr, len)
    );
  }
  return Qnil;
}

static VALUE rb_cBignum_ffi_yajl(VALUE self, VALUE rb_yajl_gen, VALUE state) {
  yajl_gen_status status;
  ID sym_to_s = rb_intern("to_s");
  VALUE str = rb_funcall(self, sym_to_s, 0);
  char *cptr = RSTRING_PTR(str);
  int len = RSTRING_LEN(str);
  struct yajl_gen_t *yajl_gen;
  Data_Get_Struct(rb_yajl_gen, struct yajl_gen_t, yajl_gen);
  if (memcmp(cptr, "NaN", 3) == 0 || memcmp(cptr, "Infinity", 8) == 0 || memcmp(cptr, "-Infinity", 9) == 0) {
    rb_raise(cEncodeError, "'%s' is an invalid number", cptr);
  }
  if ( rb_hash_aref(state, rb_str_new2("processing_key")) == Qtrue ) {
    CHECK_STATUS(
      yajl_gen_string(yajl_gen, (unsigned char *)cptr, len)
    );
  } else {
    CHECK_STATUS(
      yajl_gen_number(yajl_gen, cptr, len)
    );
  }
  return Qnil;
}

static VALUE rb_cFloat_ffi_yajl(VALUE self, VALUE rb_yajl_gen, VALUE state) {
  yajl_gen_status status;
  ID sym_to_s = rb_intern("to_s");
  VALUE str = rb_funcall(self, sym_to_s, 0);
  char *cptr = RSTRING_PTR(str);
  int len = RSTRING_LEN(str);
  struct yajl_gen_t *yajl_gen;
  Data_Get_Struct(rb_yajl_gen, struct yajl_gen_t, yajl_gen);
  if (memcmp(cptr, "NaN", 3) == 0 || memcmp(cptr, "Infinity", 8) == 0 || memcmp(cptr, "-Infinity", 9) == 0) {
    rb_raise(cEncodeError, "'%s' is an invalid number", cptr);
  }
  if ( rb_hash_aref(state, rb_str_new2("processing_key")) == Qtrue ) {
    CHECK_STATUS(
      yajl_gen_string(yajl_gen, (unsigned char *)cptr, len)
    );
  } else {
    CHECK_STATUS(
      yajl_gen_number(yajl_gen, cptr, len)
    );
  }
  return Qnil;
}

static VALUE rb_cString_ffi_yajl(VALUE self, VALUE rb_yajl_gen, VALUE state) {
  yajl_gen_status status;
  struct yajl_gen_t *yajl_gen;
  Data_Get_Struct(rb_yajl_gen, struct yajl_gen_t, yajl_gen);
  CHECK_STATUS(
    yajl_gen_string(yajl_gen, (unsigned char *)RSTRING_PTR(self), RSTRING_LEN(self))
  );
  return Qnil;
}

/* calls #to_s on an object to encode it */
static VALUE object_to_s_ffi_yajl(VALUE self, VALUE rb_yajl_gen, VALUE state) {
  yajl_gen_status status;
  ID sym_to_s = rb_intern("to_s");
  VALUE str = rb_funcall(self, sym_to_s, 0);
  char *cptr = RSTRING_PTR(str);
  int len = RSTRING_LEN(str);
  struct yajl_gen_t *yajl_gen;
  Data_Get_Struct(rb_yajl_gen, struct yajl_gen_t, yajl_gen);
  CHECK_STATUS(
    yajl_gen_string(yajl_gen, (unsigned char *)cptr, len)
  );
  return Qnil;
}

static VALUE rb_cSymbol_ffi_yajl(VALUE self, VALUE rb_yajl_gen, VALUE state) {
  return object_to_s_ffi_yajl(self, rb_yajl_gen, state);
}

static VALUE rb_cDate_ffi_yajl(VALUE self, VALUE rb_yajl_gen, VALUE state) {
  return object_to_s_ffi_yajl(self, rb_yajl_gen, state);
}

static VALUE rb_cTime_ffi_yajl(VALUE self, VALUE rb_yajl_gen, VALUE state) {
  yajl_gen_status status;
  ID sym_strftime = rb_intern("strftime");
  VALUE str = rb_funcall(self, sym_strftime, 1, rb_str_new2("%Y-%m-%d %H:%M:%S %z"));
  char *cptr = RSTRING_PTR(str);
  int len = RSTRING_LEN(str);
  struct yajl_gen_t *yajl_gen;
  Data_Get_Struct(rb_yajl_gen, struct yajl_gen_t, yajl_gen);
  CHECK_STATUS(
    yajl_gen_string(yajl_gen, (unsigned char *)cptr, len)
  );
  return Qnil;
}

static VALUE rb_cDateTime_ffi_yajl(VALUE self, VALUE rb_yajl_gen, VALUE state) {
  return object_to_s_ffi_yajl(self, rb_yajl_gen, state);
}

static VALUE rb_cObject_ffi_yajl(VALUE self, VALUE rb_yajl_gen, VALUE state) {
  yajl_gen_status status;
  ID sym_to_json = rb_intern("to_json");
  VALUE str;

  if ( rb_respond_to(self, sym_to_json) ) {
    VALUE json_opts =  rb_hash_aref(state, rb_str_new2("json_opts"));
    struct yajl_gen_t *yajl_gen;
    Data_Get_Struct(rb_yajl_gen, struct yajl_gen_t, yajl_gen);

    str = rb_funcall(self, sym_to_json, 1, json_opts);
    CHECK_STATUS(
      yajl_gen_number(yajl_gen, (char *)RSTRING_PTR(str), RSTRING_LEN(str))
    );
  } else {
    object_to_s_ffi_yajl(self, rb_yajl_gen, state);
  }

  return Qnil;
}

void Init_encoder() {
  mFFI_Yajl = rb_define_module("FFI_Yajl");
  mEncoder2 = rb_define_class_under(mFFI_Yajl, "Encoder", rb_cObject);
  cEncodeError = rb_define_class_under(mFFI_Yajl, "EncodeError", rb_eStandardError);
  mExt = rb_define_module_under(mFFI_Yajl, "Ext");
  mEncoder = rb_define_module_under(mExt, "Encoder");
  cYajl_Gen = rb_define_class_under(mEncoder, "YajlGen", rb_cObject);
  rb_define_method(mEncoder, "do_yajl_encode", mEncoder_do_yajl_encode, 3);

  cDate = rb_define_class("Date", rb_cObject);
  cTime = rb_define_class("Time", rb_cObject);
  cDateTime = rb_define_class("DateTime", cDate);

  rb_define_method(rb_cHash, "ffi_yajl", rb_cHash_ffi_yajl, 2);
  rb_define_method(rb_cArray, "ffi_yajl", rb_cArray_ffi_yajl, 2);
  rb_define_method(rb_cNilClass, "ffi_yajl", rb_cNilClass_ffi_yajl, 2);
  rb_define_method(rb_cTrueClass, "ffi_yajl", rb_cTrueClass_ffi_yajl, 2);
  rb_define_method(rb_cFalseClass, "ffi_yajl", rb_cFalseClass_ffi_yajl, 2);
  rb_define_method(rb_cFixnum, "ffi_yajl", rb_cFixnum_ffi_yajl, 2);
  rb_define_method(rb_cBignum, "ffi_yajl", rb_cBignum_ffi_yajl, 2);
  rb_define_method(rb_cFloat, "ffi_yajl", rb_cFloat_ffi_yajl, 2);
  rb_define_method(rb_cString, "ffi_yajl", rb_cString_ffi_yajl, 2);
  rb_define_method(rb_cSymbol, "ffi_yajl", rb_cSymbol_ffi_yajl, 2);
  rb_define_method(cDate, "ffi_yajl", rb_cDate_ffi_yajl, 2);
  rb_define_method(cTime, "ffi_yajl", rb_cTime_ffi_yajl, 2);
  rb_define_method(cDateTime, "ffi_yajl", rb_cDateTime_ffi_yajl, 2);
  rb_define_method(rb_cObject, "ffi_yajl", rb_cObject_ffi_yajl, 2);
}
