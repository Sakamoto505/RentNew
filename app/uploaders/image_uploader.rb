class ImageUploader < Shrine
  plugin :validation_helpers

  Attacher.validate do
    validate_max_size 8*1024*1024, message: "максимум 8 МБ"
    validate_mime_type_inclusion ["image/jpeg", "image/png", "image/webp"]
  end
end
