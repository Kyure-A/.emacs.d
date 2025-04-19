inputs: [
  {
    type = "melpa";
    path = ../recipes;
  }
  {
    name = "gnu";
    type = "elpa";
    path = inputs.elpa.outPath + "/elpa-packages";
    auto-sync-only = true;
    exclude = [
      "bbdb"
    ];
  }
  {
    name = "melpa";
    type = "melpa";
    path = inputs.melpa.outPath + "/recipes";
    exclude = [
      "bbdb"
    ];
  }
  {
    type = "elpa";
    path = inputs.nongnu.outPath + "/elpa-packages";
    exclude = [
      "org-contrib"
    ];
  }
  {
    name = "gnu-devel";
    type = "archive";
    url = "https://elpa.gnu.org/devel/";
  }
  {
    name = "nongnu-devel";
    type = "archive";
    url = "https://elpa.nongnu.org/nongnu-devel/";
  }
  {
    name = "emacsmirror";
    type = "gitmodules";
    path = inputs.epkgs.outPath + "/.gitmodules";
  }
]
