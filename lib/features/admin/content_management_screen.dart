import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/custom_card.dart';

class ContentManagementScreen extends StatelessWidget {
  const ContentManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.contentManagement),
          bottom: TabBar(
            tabs: [
              Tab(text: localizations.news, icon: Icon(Icons.newspaper)),
              Tab(text: localizations.messages, icon: Icon(Icons.message)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _NewsManagement(),
            _MessagesManagement(),
          ],
        ),
      ),
    );
  }
}

class _NewsManagement extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        CustomCard(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(localizations.featureComingSoon)),
            );
          },
          child: ListTile(
            leading: CircleAvatar(child: Icon(Icons.add)),
            title: Text(localizations.createNews),
            subtitle: Text(localizations.createNewsHint),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
        ),
        SizedBox(height: 12),
        CustomCard(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(localizations.featureComingSoon)),
            );
          },
          child: ListTile(
            leading: CircleAvatar(child: Icon(Icons.list)),
            title: Text(localizations.manageNews),
            subtitle: Text(localizations.manageNewsHint),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
        ),
      ],
    );
  }
}

class _MessagesManagement extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        CustomCard(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(localizations.featureComingSoon)),
            );
          },
          child: ListTile(
            leading: CircleAvatar(child: Icon(Icons.add_comment)),
            title: Text(localizations.publishMessage),
            subtitle: Text(localizations.publishMessageHint),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
        ),
        SizedBox(height: 12),
        CustomCard(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(localizations.featureComingSoon)),
            );
          },
          child: ListTile(
            leading: CircleAvatar(child: Icon(Icons.history)),
            title: Text(localizations.messageHistory),
            subtitle: Text(localizations.messageHistoryHint),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
        ),
      ],
    );
  }
}
