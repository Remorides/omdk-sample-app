# Documentazione Tecnica
## Framework OMDK per Flutter


![Logo remorides](https://www.dylog.it/wp-content/uploads/2023/08/Remorides.png "Logo remorides")


*Versione 1.0*

---

**Copyright © 2025 Remorides SRL**

Tutti i diritti riservati. Questo documento contiene informazioni proprietarie di Remorides SRL.
Nessuna parte di questo documento può essere riprodotta o trasmessa in qualsiasi forma o con
qualsiasi mezzo, elettronico o meccanico, per qualsiasi scopo, senza l'espresso
permesso scritto di Remorides SRL.

---

## Indice

- [1. Introduzione](#1-introduzione)
    - [1.1 Scopo del documento](#11-scopo-del-documento)
    - [1.2 Pubblico di riferimento](#12-pubblico-di-riferimento)
    - [1.3 Cosa è OMDK](#13-cosa-è-omdk)
- [2. Architettura del Framework](#2-architettura-del-framework)
    - [2.1 Panoramica](#21-panoramica)
    - [2.2 Livelli principali](#22-livelli-principali)
        - [2.2.1 OMDK REPO](#221-omdk-repo)
        - [2.2.2 OMDK API](#222-omdk-api)
        - [2.2.3 OMDK LOCAL DATA](#223-omdk-local-data)
- [3. Installazione](#3-installazione)
    - [3.1 Aggiungere la Dipendenza OMDK](#31-aggiungere-la-dipendenza-omdk)
    - [3.2 Configurare lo Stato dell'App](#32-configurare-lo-stato-dellapp)
    - [3.3 Configurare il Bootstrap](#33-configurare-il-bootstrap)
    - [3.4 Configurare il Layer di Autenticazione](#34-configurare-il-layer-di-autenticazione)
        - [3.4.1 Nota sul Componente AuthBloc](#341-nota-sul-componente-authbloc)
    - [3.5 Implementare la Vista dell'App](#35-implementare-la-vista-dellapp)
- [4. Sviluppo Simple App](#4-sviluppo-simple-app)
    - [4.1 Struttura del progetto](#41-struttura-del-progetto)
    - [4.2 Dichiarazione e definizione di elemeneti fondamentali](#42-dichiarazione-e-definizione-di-elementi-fondamentali)
    - [4.3 App](#43-app)
    - [4.4 Struttura della cartella pages](#44-struttura-della-cartella-pages)
## 1. Introduzione

### 1.1 Scopo del documento
Questo documento fornisce una descrizione completa del framework OMDK (Open Mobile Development Kit) sviluppato da Remorides SRL. L'obiettivo principale è fornire agli sviluppatori tutte le informazioni necessarie per comprendere, utilizzare ed estendere efficacemente il framework all'interno delle loro applicazioni Flutter.


### 1.2 Pubblico di riferimento
Questa documentazione è destinata a:
- Sviluppatori di applicazioni Flutter
- Ingegneri del software che lavorano con tecnologie mobili
- Architetti di sistemi che devono integrare soluzioni OMDK
- Team di supporto che necessitano di comprendere il funzionamento del framework

### 1.3 Cosa è OMDK
OMDK (Opera Mobile Development Kit) è un framework avanzato per Flutter che offre un set completo di strumenti e servizi progettati per accelerare lo sviluppo di applicazioni mobili di alta qualità e una serie di widget personalizzabili.

Il framework implementa il design pattern BloC (Business Logic Component) progettato specificatamente per Flutter che separa la logica di business dalla UI. BloC funziona attraverso un sistema di flussi di dati unidirezionali dove gli eventi generati dall'interazione dell'utente (come tap su pulsanti o scroll) vengono inviati al BloC, che elabora questi eventi attraverso una logica di business e produce nuovi stati.

Questo approccio architetturale offre numerosi vantaggi: rende il codice più testabile isolando la logica di business, facilita la gestione di stati complessi dell'applicazione, migliora la manutenibilità separando chiaramente le responsabilità e consente un'efficiente ricostruzione della UI solo quando effettivamente necessario. OMDK semplifica l'implementazione di questi pattern, offrendo una struttura coerente per la gestione dello stato, la navigazione, l'accesso ai dati e l'interfaccia utente responsive, consentendo così agli sviluppatori di concentrarsi sulla logica di business specifica della loro applicazione.
## 2. Architettura del Framework

### 2.1 Panoramica
L'architettura di OMDK è stata progettata secondo i principi di modularità, disaccoppiamento e riusabilità. Il framework è strutturato in diversi livelli che consentono una separazione chiara delle responsabilità e facilitano la manutenzione e l'estensione del codice.


![Componenti OMDK](/images/omdk-kube_architecture-Entity.png "Componenti OMDK")

### 2.2 Livelli principali
OMDK è strutturato in tre livelli principali che collaborano per fornire un'architettura robusta e scalabile per le applicazioni Flutter:

#### 2.2.1 OMDK REPO
Il livello OMDK REPO costituisce l'interfaccia principale attraverso cui le applicazioni interagiscono con il framework. Implementa la classe `OMDKEntityRepo<T extends OMDKEntity>` che funge da canale di comunicazione centralizzato per la gestione delle entità.

Questo livello offre metodi completi per:

**Gestione degli stream di dati:**
- `getControllerStream()`: Fornisce uno stream di liste di entità per l'aggiornamento reattivo dell'interfaccia utente.
- `getIsarCollectionStream()`: Crea uno stream per monitorare modifiche alla collezione Isar.
- `getIsarQueryStream(List<String>)`: Genera uno stream basato su query specifiche.
- `getIsarItemStream(String)`: Produce uno stream per monitorare una singola entità.

**Operazioni locali:**
- Lettura di dati (`readLocalItem`, `readAllLocalItems`): Metodi sincronizzati e asincroni per accedere ai dati memorizzati localmente.
- Scrittura di dati (`saveLocalItem`, `saveLocalItems`): Funzioni per salvare entità nel database locale.
- Aggiornamento (`updateLocalItem`): Metodi per modificare entità esistenti.
- Eliminazione (`deleteLocalItem`, `deleteAllLocalItems`): Funzioni per rimuovere entità dal database locale.

**Operazioni API:**
- Recupero dati (`getPageAPIItems`, `getAPIItems`, `getAPIItem`): Metodi per ottenere dati dal backend.
- Invio dati (`postAPIItem`, `putAPIItem`): Funzioni per creare o aggiornare entità sul server.
- Eliminazione (`deleteAPIItem`, `deleteAPIItems`): Metodi per rimuovere entità dal backend.

**Gestione del controller:**
- `addPageAPIItemsToController`: Aggiunge elementi ottenuti dall'API al controller.
- `addItemToController`: Inserisce una singola entità nel controller.

Tutti questi metodi restituiscono risultati incapsulati in `Either<T, Exception>`, facilitando una gestione robusta degli errori secondo il pattern Functional Error Handling.

#### 2.2.2 OMDK API
Il livello OMDK API gestisce tutte le comunicazioni con il backend. Questa componente implementa parte della classe `OMDKEntityManager<T extends OMDKEntity>`, che è la classe padre di `OMDKEntityRepo<T extends OMDKEntity>`.

Questo livello fornisce un'interfaccia di alto livello per:

**Operazioni CRUD sulle collezioni:**
- `getItems(List<String>)`: Recupera una lista paginata di entità dal server.
- `postItems(List<T>)`: Invia più entità al server contemporaneamente.
- `putItems(List<T>)`: Aggiorna più entità sul server.
- `deleteItems(List<String>)`: Rimuove più entità specificando i loro identificatori.

**Operazioni CRUD su singole entità:**
- `getItem(String)`: Recupera una singola entità dal backend.
- `postItem(T)`: Crea una nuova entità sul server.
- `putItem(T)`: Aggiorna una singola entità esistente.
- `deleteItem(String)`: Elimina una specifica entità.

Questo livello astrae la complessità delle chiamate HTTP e gestisce automaticamente la serializzazione/deserializzazione dei dati, offrendo un'interfaccia fluida per interagire con le API del backend.

#### 2.2.3 OMDK LOCAL DATA
Il livello OMDK LOCAL DATA si occupa della persistenza dei dati a livello locale, utilizzando Isar come motore di database. Questo livello implementa:

**Parte della classe `OMDKEntityManager<T extends OMDKEntity>`:**
- `onQueryChanged(Query<T>, {bool})`: Crea stream reattivi in risposta a modifiche nelle query.
- `getCollectionSize(bool, bool)`: Determina la dimensione della collezione con opzioni per filtrare elementi eliminati.
- `getCollectionSizeSync(bool, bool)`: Versione sincrona per ottenere la dimensione della collezione.

**La classe `IsarCollectionService<T extends OMDKEntity>`**, che è un **servizio interno** usato dal **manager locale dell'entità** e fornisce metodi completi per:

**Gestione della collezione:**
- `openCollection(CollectionSchema<T>, String)`: Inizializza e apre una collezione Isar.
- Metodi per osservare modifiche (`watchItem`, `watchLazyCollection`, `watchQuery`): Creano stream reattivi per monitorare cambiamenti nei dati.

**Operazioni CRUD:**
- Aggiunta di dati (`add`, `addAll`): Inserisce entità nella collezione, con versioni sincrone e asincrone.
- Lettura di dati (`read`, `readRange`, `readAll`): Recupera entità dalla collezione locale.
- Aggiornamento di dati (`updateOrInsert`, `update`): Modifica entità esistenti o ne crea di nuove.
- Eliminazione di dati (`delete`, `deleteAll`): Rimuove entità dalla collezione.

**Gestione avanzata:**
- `importJson(List<Map<String, dynamic>>)`: Importa dati in formato JSON nella collezione.
- `clearCollection()`: Rimuove tutti i dati dalla collezione.
- Metodi di analisi (`getCollectionSize`): Forniscono informazioni sulla dimensione e lo stato della collezione.

Questo livello gestisce in modo efficiente la sincronizzazione tra dati locali e remoti, migliorando le prestazioni dell'applicazione e permettendo il funzionamento offline.


## 3. Installazione

### 3.1 Aggiungere la Dipendenza OMDK

Nel file `pubspec.yaml` aggiungi la repository di OMDK come dipendenza:

```yaml
dependencies:
  # Altre dipendenze...
  
  omdk_repo:
    git:
      url: https://github.com/Remorides/omdk-repo.git
      ref: main
```

### 3.2 Configurare lo Stato dell'App

Nel file `app.dart`, definisci la classe principale dell'app:

```dart
class App extends StatefulWidget {
  /// Build [App] instance
  const App({
    required this.defaultTheme,
    required this.authRepo,
    required this.omdkApi,
    required this.omdkLocalData,
    super.key,
  });

  /// [AuthRepo] instance
  final AuthRepo authRepo;

  /// [OMDKApi] instance
  final OMDKApi omdkApi;

  /// [OMDKLocalData] instance
  final OMDKLocalData omdkLocalData;

  /// Default theme for the application
  final ThemeData defaultTheme;

  @override
  State<App> createState() => _AppState();
}
```

### 3.3 Configurare il Bootstrap

Nel file `bootstrap.dart`:

1. Importa il package OMDK:
   ```dart
   import 'package:omdk_repo/omdk_repo.dart';
   ```

2. Inizializza `omdkApi`:
   ```dart
   final omdkApi = OMDKApi(
     connectTimeout: fConfig['connectTimeout'] as Duration?,
     receiveTimeout: fConfig['receiveTimeout'] as Duration?,
     sendTimeout: fConfig['sendTimeout'] as Duration?,
     logEnabled: fConfig['logEnabled'] as bool?,
     logRequest: fConfig['logRequest'] as bool?,
     logRequestHeader: fConfig['logRequestHeader'] as bool?,
     logRequestBody: fConfig['logRequestBody'] as bool?,
     logResponseHeader: fConfig['logResponseHeader'] as bool?,
     logResponseBody: fConfig['logResponseBody'] as bool?,
   );
   ```

3. Inizializza `omdkLocalData`:
   ```dart
   final omdkLocalData = OMDKLocalData(
     analyticsEnabled: fConfig['analyticsEnabled'] as bool?,
     crashlyticsEnabled: fConfig['crashlyticsEnabled'] as bool?,
   );
   ```

4. Configura `authRepo`:
   ```dart
   final authRepo = AuthRepo(
     authApi: authApi,
     localData: omdkLocalData,
     omdkApi: omdkApi,
     crashlyticsEnabled: fConfig['crashlyticsEnabled'] as bool? ?? false,
     analyticsEnabled: fConfig['analyticsEnabled'] as bool? ?? false,
   );
   ```

5. Avvia l'app passando tutte le dipendenze necessarie:
   ```dart
   runApp(
     App(
       authRepo: authRepo,
       omdkApi: omdkApi,
       omdkLocalData: omdkLocalData,
       defaultTheme: defaultTheme,
     ),
   );
   ```

### 3.4 Configurare il Layer di Autenticazione

Nel file `app.dart`, all'interno della classe `_AppState`, implementa il metodo `build`:

```dart
@override
Widget build(BuildContext context) {
  return MultiRepositoryProvider(
    providers: [
      // Altri repository providers...
    ],
    child: MultiProvider(
      providers: [
        // Altri provider...
        BlocProvider(
          create: (_) => AuthBloc(
            authRepo: widget.authRepo,
            localData: widget.omdkLocalData,
          )..add(
              paramOTP != null
                  ? ValidateOTP(otp: paramOTP!)
                  : RestoreSession(),
            ),
        ),
      ],
      child: const AppView(),
    ),
  );
}
```

#### 3.4.1 Nota sul Componente AuthBloc

Il componente `AuthBloc` è fornito dalla nostra libreria ma è completamente personalizzabile in base alle vostre esigenze specifiche. Questo blocco gestisce l'autenticazione dell'applicazione ed è progettato per essere flessibile e adattabile.

Per esempio, potete estendere la funzionalità del blocco aggiungendo nuovi eventi o modificando la gestione degli stati esistenti:

```dart
// Esempio di personalizzazione di AuthBloc
class CustomAuthBloc extends AuthBloc {
  CustomAuthBloc({
    required AuthRepo authRepo,
    required OMDKLocalData localData,
  }) : super(authRepo: authRepo, localData: localData) {
    // Aggiunta di un nuovo evento personalizzato
    on<RefreshUserProfile>(_onRefreshUserProfile);
  }

  Future<void> _onRefreshUserProfile(
    RefreshUserProfile event, 
    Emitter<AuthState> emit,
  ) async {
    // Implementazione personalizzata per aggiornare il profilo utente
  }
}
```

Questa flessibilità vi permette di adattare il sistema di autenticazione alle specifiche necessità del vostro progetto, mantenendo al contempo la robusta struttura di base che abbiamo fornito.

### 3.5 Implementare la Vista dell'App

Nel file `app.dart`, all'interno della classe `AppView`, implementa il metodo `build`:

```dart
@override
Widget build(BuildContext context) {
  return FlavorBanner(
    child: MaterialApp(
      // Configurazione MaterialApp...
    ),
  );
}
```

## 4. Sviluppo Simple App
Quest'app, dopo che l'utente si è loggato, mostra una lista di utenti e cliccandone uno mostra i dettagli di ciascun utente.
## 4.1 Struttura del progetto
![Struttura Progetto](/images/struttura.png "Struttura Progetto")

a livello di root vi è la cartella `lib`. Questa cartella contiene il codice della nostra applicazione. è composta dai diversi main, il file `bootstrap.dart` e diverse cartelle.
I diversi main rappresentano quello che in sviluppo software viene chiamato "environment configuration" o "flavor", una pratica molto comune nello sviluppo di applicazioni mobili. Ogni file configura l'applicazione per un ambiente specifico:
- `main_dev.dart`: Configurazione per l'ambiente di sviluppo (Development)
- `main_prod.dart`: Configurazione per l'ambiente di produzione (Production)
- `main_stg.dart`: Configurazione per l'ambiente di staging (Staging)

Il file `bootstrap.dart` è il punto centrale di inizializzazione dell'applicazione Flutter, richiamato da tutti i diversi ambienti (dev, staging, prod).

- **API Setup**: Configura `OMDKApi` con l'endpoint appropriato
- **Storage**: Inizializza `OMDKLocalData` e configura `HydratedBloc.storage` per la persistenza dei bloc
- **Gestione errori**: Imposta un handler globale con `FlutterError.onError`
- **Pattern BLoC**: Registra `AppBlocObserver` per monitorare gli eventi bloc
- **Repository**: Crea e configura `AuthRepo` collegando API e storage locale
- **Temi**: Carica il tema predefinito dell'applicazione
- **Avvio**: Chiama `runApp()` iniettando tutte le dipendenze al widget principale `App`


## 4.2 Dichiarazione e definizione di elementi fondamentali

In `bootstrap.dart`, inizializziamo diversi componenti critici che costituiscono l'infrastruttura centrale dell'applicazione. Questi elementi lavorano in sinergia per garantire il corretto funzionamento del sistema.

### Client API

Inizializziamo il client API che gestirà tutte le comunicazioni con il backend:

```dart
/// Initialize api client with environment api endpoint
final omdkApi = OMDKApi(
  baseUrl: 'https://www.test.remorides.cloud/OperaAPI_V6_0/api',
);
```

Questo client è configurato con l'endpoint appropriato e fungerà da punto di accesso centralizzato per tutte le chiamate di rete dell'applicazione.

### Gestore dati locali

Creiamo un'istanza del gestore di dati locali per la persistenza delle informazioni sul dispositivo:

```dart
final omdkLocalData = OMDKLocalData();
```

Questa classe si occupa di gestire cache, preferenze utente e altri dati che devono persistere tra le sessioni.

### Gestione globale degli errori

Configuriamo un handler centralizzato per intercettare e registrare tutti gli errori dell'applicazione:

```dart
FlutterError.onError = (details) {
  omdkLocalData.logManager.log(
    LogType.error,
    details.exceptionAsString(),
    stackTrace: details.stack,
  );
};
```

Questo meccanismo assicura che nessun errore passi inosservato, facilitando debugging e monitoraggio.

### Repository di autenticazione

Implementiamo il repository di autenticazione seguendo il pattern di dependency injection:

```dart
final IAuthApi<AuthSession> authApi = OperaApiAuth(omdkApi.apiClient);
final authRepo = AuthRepo(
  authApi: authApi,
  localData: omdkLocalData,
  omdkApi: omdkApi,
);
```

Questo repository gestisce le operazioni di login, logout e sessione utente, interfacciandosi sia con le API remote che con lo storage locale.

### Tema dell'applicazione

Carichiamo il tema predefinito per l'interfaccia utente:

```dart
final defaultTheme = await omdkLocalData.themeManager.getTheme(
  ThemeEnum.light,
);
```

Questa configurazione determina l'aspetto visivo iniziale dell'applicazione, garantendo un'esperienza utente coerente fin dal primo avvio.

## 4.3 App

La classe `App` costituisce il punto di ingresso primario dell'applicazione, implementando l'inizializzazione dei provider, repository e la configurazione dell'interfaccia utente.

### Interfaccia pubblica

```dart
class App extends StatefulWidget {
  const App({
    required this.defaultTheme,
    required this.authRepo,
    required this.omdkApi,
    required this.omdkLocalData,
    super.key,
  });

  final AuthRepo authRepo;
  final OMDKApi omdkApi;
  final OMDKLocalData omdkLocalData;
  final ThemeData defaultTheme;
}
```

### Ciclo di vita e inizializzazione

Al momento dell'inizializzazione, vengono istanziati:
- `ConnectivityProvider`: fornisce notifiche sullo stato della connettività di rete
- `OperaAttachmentRepo`: gestisce il repository degli allegati con configurazione differenziata tra web e mobile

```dart
@override
void initState() {
  super.initState();
  _connectivityProvider = ConnectivityProvider();
  _attachmentRepo = OperaAttachmentRepo(
    OperaApiAttachment(widget.omdkApi.apiClient),
    entityIsarSchema: !kIsWeb ? AttachmentSchema : null,
    connectivityProvider: _connectivityProvider,
  );
}
```

### Gerarchia dei Provider

La struttura del widget tree implementa un pattern di dependency injection mediante provider:

```dart
MultiRepositoryProvider(
  providers: [
    RepositoryProvider.value(value: widget.authRepo),
    RepositoryProvider.value(value: _attachmentRepo),
    // Altri repository...
  ],
  child: MultiProvider(
    // Provider di servizi e stato...
  )
)
```

### Repository Disponibili

- `AuthRepo`: gestione dell'autenticazione
- `AttachmentRepo`: gestione degli allegati
- `OMDKLocalData`: persistenza locale
- `OperaUtils`: utilità condivise
- `OperaUserRepo`: gestione degli utenti

### Provider di Stato

```dart
MultiProvider(
  providers: [
    RouteObserverProvider(),
    ChangeNotifierProvider.value(value: _connectivityProvider),
    BlocProvider(
      create: (_) => AuthBloc(
        authRepo: widget.authRepo,
        localData: widget.omdkLocalData,
      )..add(
          paramOTP != null
              ? ValidateOTP(otp: paramOTP!)
              : RestoreSession(),
        ),
    ),
  ],
  child: AppView(theme: widget.defaultTheme),
)
```

### AppView

`AppView` implementa la configurazione di `MaterialApp` con:

- `RouteManager.generateRoute`: configurazione del sistema di routing
- `splashRoute`: rotta iniziale
- Internazionalizzazione con supporto per EN, IT, ES, FR
- Tema configurabile

### Gestione dell'autenticazione

L'implementazione utilizza `BlocListener` per reagire agli stati di autenticazione:

```dart
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) async {
    switch (state.status) {
      case AuthStatus.authenticated:
        await _navigator.pushNamedAndRemoveUntil(homeRoute, (route) => false);
      case AuthStatus.unauthenticated:
        await _navigator.pushNamedAndRemoveUntil(loginRoute, (route) => false);
      // Altri stati...
    }
  },
  child: child,
)
```

### Stati di autenticazione gestiti

- `AuthStatus.authenticated`: navigazione verso homeRoute
- `AuthStatus.unauthenticated`: navigazione verso loginRoute
- `AuthStatus.unknown`: stato iniziale in attesa di cambiamenti
- `AuthStatus.tokenExpired`: gestione token non più valido
- `AuthStatus.otpFailed`: gestione fallimento OTP
- `AuthStatus.conflicted`: gestione conflitti di autenticazione

## 4.4 Struttura della cartella Pages

La cartella `pages` rappresenta il nucleo dell'applicazione, dove vengono implementate sia la business logic che l'interfaccia utente seguendo il pattern BLoC (Business Logic Component).

### Pattern BLoC

L'applicazione adotta il pattern BLoC come architettura principale per la separazione delle responsabilità. Questa implementazione:

- Separa la UI dalla logica di business
- Migliora la testabilità del codice
- Consente un flusso di dati unidirezionale e predicibile
- Facilita la gestione degli stati dell'applicazione

### Organizzazione delle Pages

Ogni schermata dell'applicazione è organizzata seguendo una struttura coerente:

```
pages/
  ├── feature_name/
  │   ├── bloc/
  │   │   ├── feature_bloc.dart
  │   │   ├── feature_event.dart
  │   │   └── feature_state.dart
  │   ├── view/
  │       ├── feature_page.dart
  │       └── feature_view.dart

```

### Componenti principali

1. **Bloc**: Contiene la business logic della feature
    - `feature_bloc.dart`: Implementa la logica di gestione degli eventi
    - `feature_event.dart`: Definisce gli eventi che possono essere inviati al bloc
    - `feature_state.dart`: Definisce i possibili stati della feature

2. **View**: Contiene i componenti dell'interfaccia utente
    - `feature_page.dart`: Configura i provider necessari e fornisce le dipendenze
    - `feature_view.dart`: Implementa l'interfaccia utente reagendo agli stati del bloc

3. **Widgets**: Contiene widget riutilizzabili specifici della feature

