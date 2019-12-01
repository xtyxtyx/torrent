String decodeIpv4(List<int> ipv4) {
  return ipv4.sublist(0, 4).join('.');
}