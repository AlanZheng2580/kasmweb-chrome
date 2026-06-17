function FindProxyForURL(url, host) {
  // Bypass proxy for localhost and internal hosts
  if (host === 'localhost' || host === '127.0.0.1') {
    return 'DIRECT';
  }

  // Route internal domain through corporate proxy
  if (shExpMatch(host, '*.internal.example.com')) {
    return 'PROXY proxy.internal.example.com:8080';
  }

  // Route all other traffic directly
  return 'DIRECT';
}
