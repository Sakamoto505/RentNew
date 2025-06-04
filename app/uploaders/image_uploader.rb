class ImageUploader < Shrine
  plugin :validation_helpers

  Attacher.validate do
    validate_max_size 5*1024*1024, message: "максимум 5 МБ"
    validate_mime_type_inclusion ["image/jpeg", "image/png", "image/webp"]
  end
end
