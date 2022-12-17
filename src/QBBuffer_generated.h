// automatically generated by the FlatBuffers compiler, do not modify


#ifndef FLATBUFFERS_GENERATED_QBBUFFER_H_
#define FLATBUFFERS_GENERATED_QBBUFFER_H_

#include "flatbuffers/flatbuffers.h"

// Ensure the included flatbuffers.h is the same version as when this file was
// generated, otherwise it may not be compatible.
static_assert(FLATBUFFERS_VERSION_MAJOR == 22 &&
              FLATBUFFERS_VERSION_MINOR == 10 &&
              FLATBUFFERS_VERSION_REVISION == 26,
             "Non-compatible flatbuffers version included");

struct ImageMetadata;
struct ImageMetadataBuilder;

struct QBBuffer;
struct QBBufferBuilder;

enum BufferType : int8_t {
  BufferType_image = 0,
  BufferType_MIN = BufferType_image,
  BufferType_MAX = BufferType_image
};

inline const BufferType (&EnumValuesBufferType())[1] {
  static const BufferType values[] = {
    BufferType_image
  };
  return values;
}

inline const char * const *EnumNamesBufferType() {
  static const char * const names[2] = {
    "image",
    nullptr
  };
  return names;
}

inline const char *EnumNameBufferType(BufferType e) {
  if (flatbuffers::IsOutRange(e, BufferType_image, BufferType_image)) return "";
  const size_t index = static_cast<size_t>(e);
  return EnumNamesBufferType()[index];
}

enum Metadata : uint8_t {
  Metadata_NONE = 0,
  Metadata_image_metadata = 1,
  Metadata_MIN = Metadata_NONE,
  Metadata_MAX = Metadata_image_metadata
};

inline const Metadata (&EnumValuesMetadata())[2] {
  static const Metadata values[] = {
    Metadata_NONE,
    Metadata_image_metadata
  };
  return values;
}

inline const char * const *EnumNamesMetadata() {
  static const char * const names[3] = {
    "NONE",
    "image_metadata",
    nullptr
  };
  return names;
}

inline const char *EnumNameMetadata(Metadata e) {
  if (flatbuffers::IsOutRange(e, Metadata_NONE, Metadata_image_metadata)) return "";
  const size_t index = static_cast<size_t>(e);
  return EnumNamesMetadata()[index];
}

template<typename T> struct MetadataTraits {
  static const Metadata enum_value = Metadata_NONE;
};

template<> struct MetadataTraits<ImageMetadata> {
  static const Metadata enum_value = Metadata_image_metadata;
};

bool VerifyMetadata(flatbuffers::Verifier &verifier, const void *obj, Metadata type);
bool VerifyMetadataVector(flatbuffers::Verifier &verifier, const flatbuffers::Vector<flatbuffers::Offset<void>> *values, const flatbuffers::Vector<uint8_t> *types);

struct ImageMetadata FLATBUFFERS_FINAL_CLASS : private flatbuffers::Table {
  typedef ImageMetadataBuilder Builder;
  enum FlatBuffersVTableOffset FLATBUFFERS_VTABLE_UNDERLYING_TYPE {
    VT_IMAGE_ID = 4,
    VT_QUESTION_ID = 6,
    VT_FILENAME = 8
  };
  const flatbuffers::String *image_ID() const {
    return GetPointer<const flatbuffers::String *>(VT_IMAGE_ID);
  }
  const flatbuffers::String *question_ID() const {
    return GetPointer<const flatbuffers::String *>(VT_QUESTION_ID);
  }
  const flatbuffers::String *filename() const {
    return GetPointer<const flatbuffers::String *>(VT_FILENAME);
  }
  bool Verify(flatbuffers::Verifier &verifier) const {
    return VerifyTableStart(verifier) &&
           VerifyOffset(verifier, VT_IMAGE_ID) &&
           verifier.VerifyString(image_ID()) &&
           VerifyOffset(verifier, VT_QUESTION_ID) &&
           verifier.VerifyString(question_ID()) &&
           VerifyOffset(verifier, VT_FILENAME) &&
           verifier.VerifyString(filename()) &&
           verifier.EndTable();
  }
};

struct ImageMetadataBuilder {
  typedef ImageMetadata Table;
  flatbuffers::FlatBufferBuilder &fbb_;
  flatbuffers::uoffset_t start_;
  void add_image_ID(flatbuffers::Offset<flatbuffers::String> image_ID) {
    fbb_.AddOffset(ImageMetadata::VT_IMAGE_ID, image_ID);
  }
  void add_question_ID(flatbuffers::Offset<flatbuffers::String> question_ID) {
    fbb_.AddOffset(ImageMetadata::VT_QUESTION_ID, question_ID);
  }
  void add_filename(flatbuffers::Offset<flatbuffers::String> filename) {
    fbb_.AddOffset(ImageMetadata::VT_FILENAME, filename);
  }
  explicit ImageMetadataBuilder(flatbuffers::FlatBufferBuilder &_fbb)
        : fbb_(_fbb) {
    start_ = fbb_.StartTable();
  }
  flatbuffers::Offset<ImageMetadata> Finish() {
    const auto end = fbb_.EndTable(start_);
    auto o = flatbuffers::Offset<ImageMetadata>(end);
    return o;
  }
};

inline flatbuffers::Offset<ImageMetadata> CreateImageMetadata(
    flatbuffers::FlatBufferBuilder &_fbb,
    flatbuffers::Offset<flatbuffers::String> image_ID = 0,
    flatbuffers::Offset<flatbuffers::String> question_ID = 0,
    flatbuffers::Offset<flatbuffers::String> filename = 0) {
  ImageMetadataBuilder builder_(_fbb);
  builder_.add_filename(filename);
  builder_.add_question_ID(question_ID);
  builder_.add_image_ID(image_ID);
  return builder_.Finish();
}

inline flatbuffers::Offset<ImageMetadata> CreateImageMetadataDirect(
    flatbuffers::FlatBufferBuilder &_fbb,
    const char *image_ID = nullptr,
    const char *question_ID = nullptr,
    const char *filename = nullptr) {
  auto image_ID__ = image_ID ? _fbb.CreateString(image_ID) : 0;
  auto question_ID__ = question_ID ? _fbb.CreateString(question_ID) : 0;
  auto filename__ = filename ? _fbb.CreateString(filename) : 0;
  return CreateImageMetadata(
      _fbb,
      image_ID__,
      question_ID__,
      filename__);
}

struct QBBuffer FLATBUFFERS_FINAL_CLASS : private flatbuffers::Table {
  typedef QBBufferBuilder Builder;
  enum FlatBuffersVTableOffset FLATBUFFERS_VTABLE_UNDERLYING_TYPE {
    VT_SIZE = 4,
    VT_BUFFER_TYPE = 6,
    VT_METADATA_TYPE = 8,
    VT_METADATA = 10,
    VT_DATA = 12
  };
  uint64_t size() const {
    return GetField<uint64_t>(VT_SIZE, 0);
  }
  BufferType buffer_type() const {
    return static_cast<BufferType>(GetField<int8_t>(VT_BUFFER_TYPE, 0));
  }
  Metadata metadata_type() const {
    return static_cast<Metadata>(GetField<uint8_t>(VT_METADATA_TYPE, 0));
  }
  const void *metadata() const {
    return GetPointer<const void *>(VT_METADATA);
  }
  template<typename T> const T *metadata_as() const;
  const ImageMetadata *metadata_as_image_metadata() const {
    return metadata_type() == Metadata_image_metadata ? static_cast<const ImageMetadata *>(metadata()) : nullptr;
  }
  const flatbuffers::Vector<int8_t> *data() const {
    return GetPointer<const flatbuffers::Vector<int8_t> *>(VT_DATA);
  }
  bool Verify(flatbuffers::Verifier &verifier) const {
    return VerifyTableStart(verifier) &&
           VerifyField<uint64_t>(verifier, VT_SIZE, 8) &&
           VerifyField<int8_t>(verifier, VT_BUFFER_TYPE, 1) &&
           VerifyField<uint8_t>(verifier, VT_METADATA_TYPE, 1) &&
           VerifyOffset(verifier, VT_METADATA) &&
           VerifyMetadata(verifier, metadata(), metadata_type()) &&
           VerifyOffset(verifier, VT_DATA) &&
           verifier.VerifyVector(data()) &&
           verifier.EndTable();
  }
};

template<> inline const ImageMetadata *QBBuffer::metadata_as<ImageMetadata>() const {
  return metadata_as_image_metadata();
}

struct QBBufferBuilder {
  typedef QBBuffer Table;
  flatbuffers::FlatBufferBuilder &fbb_;
  flatbuffers::uoffset_t start_;
  void add_size(uint64_t size) {
    fbb_.AddElement<uint64_t>(QBBuffer::VT_SIZE, size, 0);
  }
  void add_buffer_type(BufferType buffer_type) {
    fbb_.AddElement<int8_t>(QBBuffer::VT_BUFFER_TYPE, static_cast<int8_t>(buffer_type), 0);
  }
  void add_metadata_type(Metadata metadata_type) {
    fbb_.AddElement<uint8_t>(QBBuffer::VT_METADATA_TYPE, static_cast<uint8_t>(metadata_type), 0);
  }
  void add_metadata(flatbuffers::Offset<void> metadata) {
    fbb_.AddOffset(QBBuffer::VT_METADATA, metadata);
  }
  void add_data(flatbuffers::Offset<flatbuffers::Vector<int8_t>> data) {
    fbb_.AddOffset(QBBuffer::VT_DATA, data);
  }
  explicit QBBufferBuilder(flatbuffers::FlatBufferBuilder &_fbb)
        : fbb_(_fbb) {
    start_ = fbb_.StartTable();
  }
  flatbuffers::Offset<QBBuffer> Finish() {
    const auto end = fbb_.EndTable(start_);
    auto o = flatbuffers::Offset<QBBuffer>(end);
    return o;
  }
};

inline flatbuffers::Offset<QBBuffer> CreateQBBuffer(
    flatbuffers::FlatBufferBuilder &_fbb,
    uint64_t size = 0,
    BufferType buffer_type = BufferType_image,
    Metadata metadata_type = Metadata_NONE,
    flatbuffers::Offset<void> metadata = 0,
    flatbuffers::Offset<flatbuffers::Vector<int8_t>> data = 0) {
  QBBufferBuilder builder_(_fbb);
  builder_.add_size(size);
  builder_.add_data(data);
  builder_.add_metadata(metadata);
  builder_.add_metadata_type(metadata_type);
  builder_.add_buffer_type(buffer_type);
  return builder_.Finish();
}

inline flatbuffers::Offset<QBBuffer> CreateQBBufferDirect(
    flatbuffers::FlatBufferBuilder &_fbb,
    uint64_t size = 0,
    BufferType buffer_type = BufferType_image,
    Metadata metadata_type = Metadata_NONE,
    flatbuffers::Offset<void> metadata = 0,
    const std::vector<int8_t> *data = nullptr) {
  auto data__ = data ? _fbb.CreateVector<int8_t>(*data) : 0;
  return CreateQBBuffer(
      _fbb,
      size,
      buffer_type,
      metadata_type,
      metadata,
      data__);
}

inline bool VerifyMetadata(flatbuffers::Verifier &verifier, const void *obj, Metadata type) {
  switch (type) {
    case Metadata_NONE: {
      return true;
    }
    case Metadata_image_metadata: {
      auto ptr = reinterpret_cast<const ImageMetadata *>(obj);
      return verifier.VerifyTable(ptr);
    }
    default: return true;
  }
}

inline bool VerifyMetadataVector(flatbuffers::Verifier &verifier, const flatbuffers::Vector<flatbuffers::Offset<void>> *values, const flatbuffers::Vector<uint8_t> *types) {
  if (!values || !types) return !values && !types;
  if (values->size() != types->size()) return false;
  for (flatbuffers::uoffset_t i = 0; i < values->size(); ++i) {
    if (!VerifyMetadata(
        verifier,  values->Get(i), types->GetEnum<Metadata>(i))) {
      return false;
    }
  }
  return true;
}

inline const QBBuffer *GetQBBuffer(const void *buf) {
  return flatbuffers::GetRoot<QBBuffer>(buf);
}

inline const QBBuffer *GetSizePrefixedQBBuffer(const void *buf) {
  return flatbuffers::GetSizePrefixedRoot<QBBuffer>(buf);
}

inline bool VerifyQBBufferBuffer(
    flatbuffers::Verifier &verifier) {
  return verifier.VerifyBuffer<QBBuffer>(nullptr);
}

inline bool VerifySizePrefixedQBBufferBuffer(
    flatbuffers::Verifier &verifier) {
  return verifier.VerifySizePrefixedBuffer<QBBuffer>(nullptr);
}

inline void FinishQBBufferBuffer(
    flatbuffers::FlatBufferBuilder &fbb,
    flatbuffers::Offset<QBBuffer> root) {
  fbb.Finish(root);
}

inline void FinishSizePrefixedQBBufferBuffer(
    flatbuffers::FlatBufferBuilder &fbb,
    flatbuffers::Offset<QBBuffer> root) {
  fbb.FinishSizePrefixed(root);
}

#endif  // FLATBUFFERS_GENERATED_QBBUFFER_H_
