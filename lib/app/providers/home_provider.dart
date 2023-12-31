import 'package:flutter/foundation.dart';
import 'package:variance_dart/variance.dart';
import 'package:variancewallet/app/providers/wallet_provider.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart' as w3d;

class HomeProvider with ChangeNotifier, DiagnosticableTreeMixin {
  late WalletProvider _walletProvider;
  late AlchemyTokenApi _tokenApi;
  late AlchemyTransferApi _transferApi;

  final pr = BaseProvider(
      "https://eth-mainnet.g.alchemy.com/v2/cLTpHWqs6iaOgFrnuxMVl9Z1Ung00otf");

  HomeProvider() {
    _walletProvider = WalletProvider();
    _tokenApi = AlchemyTokenApi(pr);
    _transferApi = AlchemyTransferApi(pr);
  }
  List<Token> _token = List.unmodifiable([]);
  List<Transfer> _transferData = List.unmodifiable([]);
  bool _isLoading = true;

  //getters
  List<Token> get token => _token;
  List<Transfer> get transferData => _transferData;
  EthereumAddress get address => _testAddress;
  bool get isLoading => _isLoading;

  final _testAddress = w3d.EthereumAddress.fromHex(
    "0x104EDD9708fFeeCd0b6bAaA37387E155Bce7d060",
  );
  // final _testChain = "eth-mainnet";

  void _updateIsLoading(bool value) {
    _isLoading = value;
  }

  Future<void> getData({
    w3d.EthereumAddress? address,
    String? chain,
  }) async {
    final usableAddress = address ?? _testAddress;
    final transfers =
        await _transferApi.getAssetTransfers(usableAddress, withMetadata: true);
    final token = await _tokenApi.getBalances(usableAddress);
    await _tokenApi.getTokenMetadata(usableAddress);

    _transferData = transfers;
    _token = token;
    _updateIsLoading(false);

    notifyListeners();
  }

  Future<EthereumAddress> getPasskeyAccountAddress(
      Uint8List credentialHex, Uint256 x, Uint256 y, Uint256 salt) async {
    return _walletProvider.wallet
        .getPassKeyAccountAddress(credentialHex, x, y, salt);
  }
}
