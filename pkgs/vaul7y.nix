{ buildGoModule, fetchFromGitHub, ... }:
buildGoModule {
  pname = "vaul7y";
  version = "v0.1.9";

  subPackages = ["cmd/vaul7y"];

  src = fetchFromGitHub {
    owner = "dkyanakiev";
    repo = "vaul7y";
    rev = "16109869168d0e459fd6841de1682287425653a1";
    hash = "sha256-3Ui+J9GTQC6gYbBlU6oKN7MSa2t2/InK6t0E75CdWyQ=";
  };

  vendorHash = "sha256-dSf0hojMNZ5YeDVI3Q8rNe2VXDJf/M562iZzsJTWtdY=";
}
