let
  users = {
    babeuh = "age1yubikey1qtgrhjey60y8zv62tek00fz3jvs2g3rd46zaphpd446an97aq9dycyta4y2";
    babeuh-backup = "age1yubikey1qtufjgm5g7lem0na7sd4uhusk7z3uu2jpmknrfl62rpm6e957hr42kcamhw";
  };
in
{
  "babeuh-password.age".publicKeys = [ users.babeuh users.babeuh-backup ];
}
