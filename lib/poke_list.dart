import 'package:flutter/material.dart';
import 'package:pokemon_zukan/const/pokeapi.dart';
import 'package:pokemon_zukan/models/favorite.dart';
import 'package:pokemon_zukan/models/pokemon.dart';
import 'package:pokemon_zukan/poke_list_item.dart';
import 'package:provider/provider.dart';

class PokeList extends StatefulWidget {
  const PokeList({Key? key}) : super(key: key);

  @override
  _PokeListState createState() => _PokeListState();
}

class _PokeListState extends State<PokeList> {
  static const int pageSize = 30;
  bool isFavoriteMode = false;
  int _currentPage = 1;

  bool isLastPage(int favsCount, int page) {
    if (isFavoriteMode) {
      if (page * pageSize < favsCount) {
        return false;
      }
      return true;
    }

    if (page * pageSize < pokeMaxId) {
      return false;
    }
    return true;
  }

  int itemCount(int favsCount, int page) {
    int ret = page * pageSize;
    if (isFavoriteMode && ret > favsCount) {
      ret = favsCount;
    }
    if (ret > pokeMaxId) {
      ret = pokeMaxId;
    }

    return ret;
  }

  int itemId(List<Favorite> favs, int index) {
    int ret = index + 1;
    if (isFavoriteMode && index < favs.length) {
      ret = favs[index].pokeId;
    }

    return ret;
  }

  void changeMode(bool currentMode) {
    setState(() => isFavoriteMode = !currentMode);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesNotifier>(
        builder: (context, favs, child) => Column(children: [
              Container(
                  height: 24,
                  alignment: Alignment.topRight,
                  child: IconButton(
                      padding: const EdgeInsets.all(0),
                      icon: const Icon(Icons.auto_awesome_outlined),
                      onPressed: () async {
                        var ret = await showModalBottomSheet<bool>(
                            context: context,
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(40),
                                    topRight: Radius.circular(40))),
                            builder: (BuildContext context) {
                              return ViewModeBottomSheet(
                                  favMode: isFavoriteMode);
                            });
                        if (ret != null && ret) {
                          changeMode(isFavoriteMode);
                        }
                      })),
              Expanded(child:
                  Consumer<PokemonsNotifier>(builder: ((context, pokes, child) {
                if (itemCount(favs.favs.length, _currentPage) == 0) {
                  return const Text('no data');
                }
                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  itemCount: itemCount(favs.favs.length, _currentPage) + 1,
                  itemBuilder: (context, index) {
                    if (index == itemCount(favs.favs.length, _currentPage)) {
                      return OutlinedButton(
                          child: const Text('more'),
                          onPressed: () => {
                                isLastPage(favs.favs.length, _currentPage)
                                    ? null
                                    : setState(() => _currentPage++)
                              });
                    } else {
                      return PokeListItem(
                        poke: pokes.byId(itemId(favs.favs, index)),
                      );
                    }
                  },
                );
              })))
            ]));
  }
}

class ViewModeBottomSheet extends StatelessWidget {
  const ViewModeBottomSheet({
    Key? key,
    required this.favMode,
  }) : super(key: key);

  final bool favMode;

  String mainText(bool fav) {
    if (fav) {
      return '?????????????????????????????????????????????????????????';
    }
    return '???????????????????????????????????????????????????';
  }

  String menuTitle(bool fav) {
    if (fav) {
      return '????????????????????????????????????';
    }
    return '??????????????????????????????????????????';
  }

  String menuSubTitle(bool fav) {
    if (fav) {
      return '??????????????????????????????????????????';
    }
    return '?????????????????????????????????????????????????????????????????????';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 300,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Center(
            child: Column(
          children: <Widget>[
            // ??????????????????????????????????????????????????????
            Container(
              height: 5,
              width: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).backgroundColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Text(mainText(favMode),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  )),
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: Text(menuTitle(favMode)),
              subtitle: Text(menuSubTitle(favMode)),
              onTap: () {
                Navigator.pop(context, true);
              },
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
              child: const Text('???????????????'),
              onPressed: () {
                Navigator.pop(context, false);
              },
            )
          ],
        )));
  }
}
