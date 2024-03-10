{
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule {
  pname = "fusion";
  version = "";

  src = fetchFromGitHub {
    owner = "edgelaboratories";
    repo = "fusion";
    rev = "v0.1.2";
    hash = "sha256-4T4NG1Xd61rYRloA97wLmYwRMeDbw2V8BvwRqWIyr/0=";
  };

  vendorHash = "sha256-r66K3Y+gTgkjILKCLJ72XpjRXmu5xbH2R1gSVZOlEcY=";
}
