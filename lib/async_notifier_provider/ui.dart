import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_practice/async_notifier_provider/model.dart';

import "package:riverpod/riverpod.dart";

import 'package:flutter/material.dart';
import 'package:riverpod_practice/async_notifier_provider/provider.dart';
class FruitsPage extends ConsumerWidget {
  const FruitsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fruitsAsync = ref.watch(fruitsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,

        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Fruits',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Manage your fruit collection',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
          ],
        ),

        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              ref.invalidate(fruitsProvider);
            },
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),

          const SizedBox(width: 8),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showFruitForm(
            context: context,
            ref: ref,
          );
        },
        icon: const Icon(
          Icons.add_rounded,
        ),
        label: const Text(
          'Add Fruit',
        ),
      ),

      body: fruitsAsync.when(
        loading: () {
          return const _InitialLoadingView();
        },

        error: (error, stackTrace) {
          return _ErrorView(
            error: error,
            onRetry: () {
              ref.invalidate(fruitsProvider);
            },
          );
        },

        data: (fruits) {
          if (fruits.isEmpty) {
            return _EmptyView(
              onAdd: () {
                _showFruitForm(
                  context: context,
                  ref: ref,
                );
              },
            );
          }

          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(fruitsProvider);

                  await ref.read(
                    fruitsProvider.future,
                  );
                },

                child: ListView(
                  physics:
                      const AlwaysScrollableScrollPhysics(),

                  padding: const EdgeInsets.fromLTRB(
                    16,
                    20,
                    16,
                    100,
                  ),

                  children: [
                    _SummaryCard(
                      count: fruits.length,
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'All Fruits',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 12),

                    ...fruits.map(
                      (fruit) {
                        return Padding(
                          padding:
                              const EdgeInsets.only(
                            bottom: 12,
                          ),
                          child: _FruitCard(
                            fruit: fruit,

                            onEdit: () {
                              _showFruitForm(
                                context: context,
                                ref: ref,
                                fruit: fruit,
                              );
                            },

                            onDelete: () {
                              _showDeleteDialog(
                                context: context,
                                ref: ref,
                                fruit: fruit,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Operation loading indicator.
              if (fruitsAsync.isLoading)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(
                    minHeight: 3,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // ADD / EDIT FORM
  // ============================================================

  static void _showFruitForm({
    required BuildContext context,
    required WidgetRef ref,
    Fruit? fruit,
  }) {
    final isEditing = fruit != null;

    final nameController = TextEditingController(
      text: fruit?.name ?? '',
    );

    final emojiController = TextEditingController(
      text: fruit?.emoji ?? '🍎',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,

      builder: (context) {
        return _FruitFormSheet(
          nameController: nameController,
          emojiController: emojiController,
          isEditing: isEditing,

          onSubmit: () async {
            final name =
                nameController.text.trim();

            final emoji =
                emojiController.text.trim();

            if (name.isEmpty) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(
                const SnackBar(
                  content: Text(
                    'Please enter fruit name',
                  ),
                ),
              );

              return;
            }

            Navigator.pop(context);

            if (isEditing) {
              await ref
                  .read(
                    fruitsProvider.notifier,
                  )
                  .updateFruit(
                    id: fruit.id,
                    name: name,
                    emoji: emoji.isEmpty
                        ? '🍎'
                        : emoji,
                  );
            } else {
              await ref
                  .read(
                    fruitsProvider.notifier,
                  )
                  .addFruit(
                    name: name,
                    emoji: emoji.isEmpty
                        ? '🍎'
                        : emoji,
                  );
            }
          },
        );
      },
    );
  }

  // ============================================================
  // DELETE DIALOG
  // ============================================================

  static void _showDeleteDialog({
    required BuildContext context,
    required WidgetRef ref,
    required Fruit fruit,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Fruit?',
          ),

          content: Text(
            'Are you sure you want to delete ${fruit.name}?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cancel',
              ),
            ),

            FilledButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                await ref
                    .read(
                      fruitsProvider.notifier,
                    )
                    .deleteFruit(
                      fruit.id,
                    );
              },

              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );
  }
}
class _SummaryCard extends StatelessWidget {
  final int count;

  const _SummaryCard({
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF5B5FEF),
            Color(0xFF7B61FF),
          ],
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,

            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius:
                  BorderRadius.circular(16),
            ),

            child: const Center(
              child: Text(
                '🍎',
                style: TextStyle(
                  fontSize: 27,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                const Text(
                  'Fruit Collection',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '$count fruits available',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class _FruitCard extends StatelessWidget {
  final Fruit fruit;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _FruitCard({
    required this.fruit,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,

            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F8),
              borderRadius:
                  BorderRadius.circular(16),
            ),

            child: Center(
              child: Text(
                fruit.emoji,
                style: const TextStyle(
                  fontSize: 30,
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  fruit.name,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Fruit ID: ${fruit.id}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                onEdit();
              }

              if (value == 'delete') {
                onDelete();
              }
            },

            itemBuilder: (context) {
              return const [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                      ),
                      SizedBox(width: 10),
                      Text('Edit'),
                    ],
                  ),
                ),

                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                      ),
                      SizedBox(width: 10),
                      Text('Delete'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }
}
class _FruitFormSheet extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emojiController;
  final bool isEditing;
  final VoidCallback onSubmit;

  const _FruitFormSheet({
    required this.nameController,
    required this.emojiController,
    required this.isEditing,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset =
        MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        bottomInset + 20,
      ),

      decoration: const BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,

              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius:
                    BorderRadius.circular(20),
              ),
            ),
          ),

          const SizedBox(height: 22),

          Text(
            isEditing
                ? 'Edit Fruit'
                : 'Add New Fruit',

            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            isEditing
                ? 'Update your fruit details'
                : 'Add a new fruit to your collection',

            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 22),

          TextField(
            controller: nameController,

            textInputAction:
                TextInputAction.next,

            decoration: InputDecoration(
              labelText: 'Fruit Name',
              hintText: 'e.g. Pineapple',

              prefixIcon: const Icon(
                Icons.eco_outlined,
              ),

              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(14),
              ),
            ),
          ),

          const SizedBox(height: 14),

          TextField(
            controller: emojiController,

            decoration: InputDecoration(
              labelText: 'Emoji',
              hintText: 'e.g. 🍍',

              prefixIcon: const Icon(
                Icons.emoji_emotions_outlined,
              ),

              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(14),
              ),
            ),
          ),

          const SizedBox(height: 22),

          SizedBox(
            width: double.infinity,
            height: 52,

            child: FilledButton(
              onPressed: onSubmit,

              child: Text(
                isEditing
                    ? 'Update Fruit'
                    : 'Add Fruit',

                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InitialLoadingView extends StatelessWidget {
  const _InitialLoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),

      children: [
        const SizedBox(height: 20),

        Container(
          height: 110,

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(20),
          ),
        ),

        const SizedBox(height: 20),

        ...List.generate(
          4,
          (index) {
            return Container(
              height: 85,
              margin:
                  const EdgeInsets.only(bottom: 12),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(18),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyView({
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Container(
              width: 90,
              height: 90,

              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),

              child: const Center(
                child: Text(
                  '🍃',
                  style: TextStyle(
                    fontSize: 42,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'No Fruits Yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Your fruit collection is empty. '
              'Add your first fruit to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: onAdd,

              icon: const Icon(
                Icons.add,
              ),

              label: const Text(
                'Add First Fruit',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _ErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Container(
              width: 80,
              height: 80,

              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),

              child: Icon(
                Icons.error_outline_rounded,
                size: 42,
                color: Colors.red.shade400,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              error.toString(),
              textAlign: TextAlign.center,

              style: const TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 22),

            FilledButton.icon(
              onPressed: onRetry,

              icon: const Icon(
                Icons.refresh,
              ),

              label: const Text(
                'Try Again',
              ),
            ),
          ],
        ),
      ),
    );
  }
}