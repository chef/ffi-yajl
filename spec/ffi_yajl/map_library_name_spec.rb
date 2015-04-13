
require 'spec_helper'

class Test
  extend FFI_Yajl::MapLibraryName
end

host_os_library_name_mapping = {
  "mingw"    => [ "libyajl.so", "yajl.dll" ],
  "mswin"    => [ "libyajl.so", "yajl.dll" ],
  "cygwin"   => [ "libyajl.so", "cygyajl.dll" ],
  "darwin"   => [ "libyajl.bundle", "libyajl.dylib" ],
  "solaris2" => [ "libyajl.so" ],
  "linux"    => [ "libyajl.so" ],
  "aix"      => [ "libyajl.so" ],
  "hpux"     => [ "libyajl.so" ],
  "netbsd"   => [ "libyajl.so" ],
  "openbsd"  => [ "libyajl.so" ],
  "freebsd"  => [ "libyajl.so" ],
}

describe "FFI_Yajl::MapLibraryName" do
  let(:libyajl2_opt_path) { "/libyajl2/lib" }
  before do
    allow(Libyajl2).to receive(:opt_path).and_return(libyajl2_opt_path)
  end

  host_os_library_name_mapping.each do |host_os, library_names|

    context "#library_names" do
      it "maps #{host_os} correctly" do
        allow(Test).to receive(:host_os).and_return(host_os)
        expect(Test.send(:library_names)).to eq(library_names)
      end
    end

    context "#expanded_library_names" do
      it "maps #{host_os} correctly" do
        allow(Test).to receive(:host_os).and_return(host_os)
        expanded_library_names = []
        library_names.each do |library_name|
          path = File.expand_path(File.join(libyajl2_opt_path, library_name))
          expanded_library_names.push(path)
          expect(File).to receive(:file?).with(path).and_return(true)
        end
        expect(Test.send(:expanded_library_names)).to eq(expanded_library_names)
      end
    end

    context "#dlopen_yajl_library" do
      it "should call dlopen against an expanded library name if it finds it on #{host_os}" do
        allow(Test).to receive(:host_os).and_return(host_os)
        library_names.each do |library_name|
          path = File.expand_path(File.join(libyajl2_opt_path, library_name))
          allow(File).to receive(:file?).with(path).and_return(true)
          allow(Test).to receive(:dlopen).with(path).and_return(nil)
        end
        Test.send(:dlopen_yajl_library)
      end
      it "if dlopen calls all raise it should still use the short names on #{host_os}" do
        allow(Test).to receive(:host_os).and_return(host_os)
        library_names.each do |library_name|
          path = File.expand_path(File.join(libyajl2_opt_path, library_name))
          allow(File).to receive(:file?).with(path).and_return(true)
          allow(Test).to receive(:dlopen).with(path).and_raise(ArgumentError)
        end
        allow(Test).to receive(:dlopen).with(library_names.first).and_return(nil)
        Test.send(:dlopen_yajl_library)
      end
    end

    context "ffi_open_yajl_library" do
      it "should call ffi_lib against an expanded library name if it finds it on #{host_os}" do
        allow(Test).to receive(:host_os).and_return(host_os)
        library_names.each do |library_name|
          path = File.expand_path(File.join(libyajl2_opt_path, library_name))
          allow(File).to receive(:file?).with(path).and_return(true)
          allow(Test).to receive(:ffi_lib).with(path).and_return(nil)
        end
        Test.send(:ffi_open_yajl_library)
      end

      it "if dlopen calls all raise it should still use 'yajl' on #{host_os}" do
        allow(Test).to receive(:host_os).and_return(host_os)
        library_names.each do |library_name|
          path = File.expand_path(File.join(libyajl2_opt_path, library_name))
          allow(File).to receive(:file?).with(path).and_return(true)
          allow(Test).to receive(:ffi_lib).with(path).and_raise(LoadError)
        end
        allow(Test).to receive(:ffi_lib).with('yajl').and_return(nil)
        Test.send(:ffi_open_yajl_library)
      end
    end

  end
end
