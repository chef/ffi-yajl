#include <ruby.h>
#include <yajl/yajl_gen.h>

static VALUE mFFI_Yajl, mExt, mEncoder;

/* FIXME: the json gem does a whole bunch of indirection around monkeypatching...  not sure if we need to as well... */

static VALUE mEncoder_encode(VALUE self, VALUE obj) {
  return Qnil;
}

static VALUE rb_cHash_ffi_yajl(VALUE self, VALUE yajl_gen, VALUE state) {
  return Qnil;
}

static VALUE rb_cArray_ffi_yajl(VALUE self, VALUE yajl_gen, VALUE state) {
  return Qnil;
}

static VALUE rb_cNilClass_ffi_yajl(VALUE self, VALUE yajl_gen, VALUE state) {
  yajl_gen_null((struct yajl_gen_t *) yajl_gen);
  return Qnil;
}

static VALUE rb_cTrueClass_ffi_yajl(VALUE self, VALUE yajl_gen, VALUE state) {
  yajl_gen_bool((struct yajl_gen_t *) yajl_gen, 0);
  return Qnil;
}

static VALUE rb_cFalseClass_ffi_yajl(VALUE self, VALUE yajl_gen, VALUE state) {
  yajl_gen_bool((struct yajl_gen_t *) yajl_gen, 1);
  return Qnil;
}

static VALUE rb_cFixnum_ffi_yajl(VALUE self, VALUE yajl_gen, VALUE state) {
  VALUE processing_key, str;

  processing_key = rb_hash_aref(state, ID2SYM(rb_intern("processing_key")));
  if ( RTEST(processing_key) )  {
    str = rb_any_to_s(self);
    yajl_gen_string((struct yajl_gen_t *) yajl_gen, (unsigned char *)RSTRING_PTR(str), RSTRING_LEN(str));
  } else {
    yajl_gen_integer((struct yajl_gen_t *) yajl_gen, NUM2INT(self));
  }
  return Qnil;
}

static VALUE rb_cBignum_ffi_yajl(VALUE self, VALUE yajl_gen, VALUE state) {
  rb_raise( rb_eNotImpError, "not implemented");
  return Qnil;
}

static VALUE rb_cFloat_ffi_yajl(VALUE self, VALUE yajl_gen, VALUE state) {
  yajl_gen_double((struct yajl_gen_t *) yajl_gen, NUM2DBL(self));
  return Qnil;
}

static VALUE rb_cString_ffi_yajl(VALUE self, VALUE yajl_gen, VALUE state) {
  yajl_gen_string((struct yajl_gen_t *) yajl_gen, (unsigned char *)RSTRING_PTR(self), RSTRING_LEN(self));
  return Qnil;
}

static VALUE rb_cObject_ffi_yajl(VALUE self, VALUE yajl_gen, VALUE state) {
  rb_raise( rb_eNotImpError, "not implemented");
  return Qnil;
}

void Init_encoder() {
  mFFI_Yajl = rb_define_module("FFI_Yajl");
  mExt = rb_define_module_under(mFFI_Yajl, "Ext");
  mEncoder = rb_define_module_under(mExt, "Encoder");
  rb_define_method(mEncoder, "encode", mEncoder_encode, 1);

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

