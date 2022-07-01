## [1.5.0] - 1 July 2022

- Add Provider mechanism for FutureManager
   - `ManagerProvider`: Create a provider for FutureManager
   - `ManagerProviderMixin`: A mixin on StatefulWidget to access FutureManager's Ref
   - `ManagerConsumer`: Access FutureManager's Ref via Stateless Widget

## [1.4.0] - 25 May 2022

- fix `isRefreshing` isn't exactly what it is
- add new field `hasDataOrError`

## [1.3.0] - 17 May 2022

- add `cacheOption` to FutureManager's constructor. You can now cache the data within given time. `asyncOperation` and `refresh` now has a parameter option to use `cache` or not

## [1.2.1] - 27 April 2022

- add `clearError` to FutureManager

## [1.2.0] - 26 April 2022

**Small breaking changes**

- add `SuraManagerProvider`
- `loadingWidget` and `ErrorWidget` in `SuraManager` now using from `SuraManagerProvider` instead of `SuraProvider`

## [1.1.0] - 25 April 2022

- `error` from Manager now has a type of `FutureManagerError` instead of dynamic

## [1.0.0] - 3 February 2022

- Stable release

## [0.2.1] - 13 January 2022

- Code refractor

## [0.2.0] - 17 December 2021

- Code improvement
- add [listen] function to FutureManager
- Add [useMicrotask] param to several method in FutureManager to prevent a bug where listener of FutureManager is deactivate when rebuilt

## [0.1.5] - 11 December 2021

- update Example
- update README
- add updateViewState param to resetData and addError to FutureManager. FutureManager now will always be rebuild when refresh is call regardless the reloading is true or false. This change was make FutureManager is work best with Pagination List. See the example for more clear insight.

#### Breaking Change

- FutureManagerBuilder param: onReady now change to onData

## [0.1.4] - 09 December 2021

- Fix issue #2

## [0.1.3] - 02 December 2021

- add onReady and add support for SuraProvider onManagerError

## [0.1.2] - 26 November 2021

- add modifyData function to FutureManager
- improve documentation

## [0.1.1] - 23 October 2021

- Fix a bug where Manager has a data but error isn't null, This lead to some inccrrect widget build since our error still exist in some way

## [0.1.0] - 28 September 2021

- update ManagerViewState when there is an error and reloading is false, This feature keep the view as previous state, just update the listener only.
  - use case: when we want to refresh the data without reloading the view and got an error, but need to rebuild the FutureManagerBuilder's child with current state.

## [0.0.9] - 19 September 2021

- Update sura_flutter package
- Expose SuraProvider from sura_flutter

## [0.0.8] - 21 August 2021

- Update sura_flutter package

## [0.0.7] - 21 August 2021

- Update sura_flutter package

## [0.0.6] - 14 August 2021

- fix issue [#1](https://github.com/asurraa/sura_manager/issues/1)

## [0.0.5] - 1 August 2021

- add hasData method back to FutureManager

## [0.0.4] - 29 July 2021

- add refreshing widget to FutureManagerBuilder

## [0.0.3+1] - 26 July 2021

- fix FutureManager loading stack

## [0.0.3] - 26 July 2021

- rework FutureManager state

## [0.0.2] - 28 June 2021

- Fix FutureManager addError doesn't trigger error

## [0.0.1] - 25 June 2021

- initial release
