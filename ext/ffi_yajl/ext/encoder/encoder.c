#include <ruby.h>
#include <yajl/yajl_gen.h>

static VALUE mFFI_Yajl, mExt, mEncoder, mEncoder2, cEncodeError;

/* FIXME: the json gem does a whole bunch of indirection around monkeypatching...  not sure if we need to as well... */

#define CHECK_STATUS(call) \
      if ((status = (call)) != yajl_gen_status_ok) { rb_funcall(mEncoder2, rb_intern("raise_error_for_status"), 1, status); }

typedef struct {
  VALUE json_opts;
  int processing_key;
} ffi_state_t;

static VALUE mEncoder_do_yajl_encode(VALUE self, VALUE obj, VALUE yajl_gen_opts) {
  ID sym_ffi_yajl = rb_intern("ffi_yajl");
  VALUE sym_yajl_gen_beautify = ID2SYM(rb_intern("yajl_gen_beautify"));
  VALUE sym_yajl_gen_validate_utf8 = ID2SYM(rb_intern("yajl_gen_validate_utf8"));
  VALUE sym_yajl_gen_indent_string = ID2SYM(rb_intern("yajl_gen_indent_string"));
  yajl_gen yajl_gen;
  const unsigned char *buf;
  size_t len;
  ffi_state_t state;
  VALUE ret;
  VALUE indent_string;

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

  state.processing_key = 0;

  rb_funcall(obj, sym_ffi_yajl, 2, yajl_gen, (VALUE) &state);

  yajl_gen_get_buf(yajl_gen, &buf, &len);

  ret = rb_str_new2((char *)buf);

  yajl_gen_free(yajl_gen);

  return ret;
}

typedef struct {
  VALUE yajl_gen;
  ffi_state_t *state;
} ffs_extra_t;

int rb_cHash_ffi_yajl_callback(VALUE key, VALUE val, VALUE extra) {
  ffs_extra_t *extra_p = (ffs_extra_t *)extra;
  ID sym_ffi_yajl = rb_intern("ffi_yajl");

  extra_p->state->processing_key = 1;
  rb_funcall(key, sym_ffi_yajl, 2, extra_p->yajl_gen, extra_p->state);
  extra_p->state->processing_key = 0;
  rb_funcall(val, sym_ffi_yajl, 2, extra_p->yajl_gen, extra_p->state);

  return ST_CONTINUE;
}

static VALUE rb_cHash_ffi_yajl(VALUE self, VALUE yajl_gen, VALUE state) {
  yajl_gen_status status;
  ffs_extra_t extra;

  extra.yajl_gen = yajl_gen;
  extra.state = (ffi_state_t *)state;

  CHECK_STATUS(
    yajl_gen_map_open((struct yajl_gen_t *) yajl_gen)
  );
  rb_hash_foreach(self, rb_cHash_ffi_yajl_callback, (VALUE) &extra);
  CHECK_STATUS(
    yajl_gen_map_close((struct yajl_gen_t *) yajl_gen)
  );

  return Qnil;
}

static VALUE rb_cArray_ffi_yajl(VALUE self, VALUE yajl_gen, VALUE state) {
  yajl_gen_status status;
  ID sym_ffi_yajl = rb_intern("ffi_yajl");
  long i;
  VALUE val;

  CHECK_STATUS(
    yajl_gen_array_open((struct yajl_gen_t *) yajl_gen)
  );
  for(i=0; i<RARRAY_LEN(self); i++) {
    val = rb_ary_entry(self, i);
    rb_funcall(val, sym_ffi_yajl, 2, yajl_gen, state);
  }
  CHECK_STATUS(
    yajl_gen_array_close((struct yajl_gen_t *) yajl_gen)
  );

  return Qnil;
}

static VALUE rb_cNilClass_ffi_yajl(VALUE self, VALUE yajl_gen, VALUE state) {
  yajl_gen_status status;
  CHECK_STATUS(
    yajl_gen_null((struct yajl_gen_t *) yajl_gen)
  );
  return Qnil;
}

static VALUE rb_cTrueClass_ffi_yajl(VALUE self, VALUE yajl_gen, VALUE state) {
  yajl_gen_status status;
  CHECK_STATUS(
    yajl_gen_bool((struct yajl_gen_t *) yajl_gen, 1)
  );
  return Qnil;
}

static VALUE rb_cFalseClass_ffi_yajl(VALUE self, VALUE yajl_gen, VALUE state) {
  yajl_gen_status status;
  CHECK_STATUS(
    yajl_gen_bool((struct yajl_gen_t *) yajl_gen, 0)
  );
  return Qnil;
}

static VALUE rb_cFixnum_ffi_yajl(VALUE self, VALUE yajl_gen, VALUE state) {
  yajl_gen_status status;
  ID sym_to_s = rb_intern("to_s");
  VALUE str = rb_funcall(self, sym_to_s, 0);
  char *cptr = RSTRING_PTR(str);
  int len = RSTRING_LEN(str);

  if (memcmp(cptr, "NaN", 3) == 0 || memcmp(cptr, "Infinity", 8) == 0 || memcmp(cptr, "-Infinity", 9) == 0) {
    rb_raise(cEncodeError, "'%s' is an invalid number", cptr);
  }
  if ( ((ffi_state_t *)state)->processing_key ) {
    CHECK_STATUS(
      yajl_gen_string((struct yajl_gen_t *) yajl_gen, (unsigned char *)cptr, len)
    );
  } else {
    CHECK_STATUS(
      yajl_gen_integer((struct yajl_gen_t *) yajl_gen, NUM2INT(self))
    );
  }
  return Qnil;
}

static VALUE rb_cBignum_ffi_yajl(VALUE self, VALUE yajl_gen, VALUE state) {
  yajl_gen_status status;
  ID sym_to_s = rb_intern("to_s");
  VALUE str = rb_funcall(self, sym_to_s, 0);
  char *cptr = RSTRING_PTR(str);
  int len = RSTRING_LEN(str);
  if (memcmp(cptr, "NaN", 3) == 0 || memcmp(cptr, "Infinity", 8) == 0 || memcmp(cptr, "-Infinity", 9) == 0) {
    rb_raise(cEncodeError, "'%s' is an invalid number", cptr);
  }
  if ( ((ffi_state_t *)state)->processing_key ) {
    CHECK_STATUS(
      yajl_gen_string((struct yajl_gen_t *) yajl_gen, (unsigned char *)cptr, len)
    );
  } else {
    CHECK_STATUS(
      yajl_gen_number((struct yajl_gen_t *) yajl_gen, cptr, len)
    );
  }
  return Qnil;
}

static VALUE rb_cFloat_ffi_yajl(VALUE self, VALUE yajl_gen, VALUE state) {
  yajl_gen_status status;
  ID sym_to_s = rb_intern("to_s");
  VALUE str = rb_funcall(self, sym_to_s, 0);
  char *cptr = RSTRING_PTR(str);
  int len = RSTRING_LEN(str);
  if (memcmp(cptr, "NaN", 3) == 0 || memcmp(cptr, "Infinity", 8) == 0 || memcmp(cptr, "-Infinity", 9) == 0) {
    rb_raise(cEncodeError, "'%s' is an invalid number", cptr);
  }
  if ( ((ffi_state_t *)state)->processing_key ) {
    CHECK_STATUS(
      yajl_gen_string((struct yajl_gen_t *) yajl_gen, (unsigned char *)cptr, len)
    );
  } else {
    CHECK_STATUS(
      yajl_gen_number((struct yajl_gen_t *) yajl_gen, cptr, len)
    );
  }
  return Qnil;
}


static VALUE rb_cString_ffi_yajl(VALUE self, VALUE yajl_gen, VALUE state) {
  yajl_gen_status status;
  CHECK_STATUS(
    yajl_gen_string((struct yajl_gen_t *) yajl_gen, (unsigned char *)RSTRING_PTR(self), RSTRING_LEN(self))
  );
  return Qnil;
}

static VALUE rb_cObject_ffi_yajl(VALUE self, VALUE yajl_gen, VALUE state) {
  yajl_gen_status status;
  ID sym_to_json = rb_intern("to_json");
  VALUE str;

  str = rb_funcall(self, sym_to_json, 1, ((ffi_state_t *)state)->json_opts);
  CHECK_STATUS(
    yajl_gen_number((struct yajl_gen_t *) yajl_gen, (char *)RSTRING_PTR(str), RSTRING_LEN(str))
  );
  return Qnil;
}

void Init_encoder() {
  mFFI_Yajl = rb_define_module("FFI_Yajl");
  mEncoder2 = rb_define_class_under(mFFI_Yajl, "Encoder", rb_cObject);
  cEncodeError = rb_define_class_under(mFFI_Yajl, "EncodeError", rb_eStandardError);
  mExt = rb_define_module_under(mFFI_Yajl, "Ext");
  mEncoder = rb_define_module_under(mExt, "Encoder");
  rb_define_method(mEncoder, "do_yajl_encode", mEncoder_do_yajl_encode, 2);

  rb_define_method(rb_cHash, "ffi_yajl", rb_cHash_ffi_yajl, 2);
  rb_define_method(rb_cArray, "ffi_yajl", rb_cArray_ffi_yajl, 2);
  rb_define_method(rb_cNilClass, "ffi_yajl", rb_cNilClass_ffi_yajl, 2);
  rb_define_method(rb_cTrueClass, "ffi_yajl", rb_cTrueClass_ffi_yajl, 2);
  rb_define_method(rb_cFalseClass, "ffi_yajl", rb_cFalseClass_ffi_yajl, 2);
  rb_define_method(rb_cFixnum, "ffi_yajl", rb_cFixnum_ffi_yajl, 2);
  rb_define_method(rb_cBignum, "ffi_yajl", rb_cBignum_ffi_yajl, 2);
  rb_define_method(rb_cFloat, "ffi_yajl", rb_cFloat_ffi_yajl, 2);
  rb_define_method(rb_cString, "ffi_yajl", rb_cString_ffi_yajl, 2);
  rb_define_method(rb_cObject, "ffi_yajl", rb_cObject_ffi_yajl, 2);
}

