{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Head Gardener";
        email = "trashbin2019np@gmail.com";
      };
      diff.tool = "nvimdiff";
      merge.tool = "nvimdiff";
    };
  };
}
