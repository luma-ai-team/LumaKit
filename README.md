# LumaKit

A description of this package.

## CodeGen setup

Install general
```
brew install rosberry/tap/general
``` 

In the project root directory, run
```
general setup -r "disabled/general-templates ios"
```

To generate a module, run
```
general gen -n <module-name> -t rsb_generic_module
```

By default, new modules are generated in `Classes/Presentation/Modules` directory.
This can be changed by editing `.general.yml` in the root project directory.
