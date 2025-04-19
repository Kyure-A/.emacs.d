{lib}:
with builtins; {
  counsel = _: super: {
    files = removeAttrs super.files [
      "elpa.el"
      "ivy-avy.el"
      "ivy-faces.el"
      "ivy-hydra.el"
      "ivy-overlay.el"
      "ivy.el"
      "swiper.el"
    ];
  };
}
