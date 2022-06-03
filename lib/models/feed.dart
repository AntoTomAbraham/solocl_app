class feed {
  String image;
  String placeholder;
  feed({
    required this.image,
    required this.placeholder,
  });
  feed.fromJson(Map<String, Object?> json)
      : this(
          image: json['image']! as String,
          placeholder: json['placeholder']! as String,
        );

  Map<String, String?> toJson() => {
        "image": image,
        "placeholder": placeholder,
      };
}
