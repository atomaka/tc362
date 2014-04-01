# TC362 - Web Administration

## Installation

Download the bootstrap script, set as executable, and run as root.

## Usage

```
./bootstrap -s
```

Setup a server using the site.pp manifest and the master branch.

```
./bootstrap -s -m final.pp
```

Setup the server from the final project manifest

```
./bootstrap
```

Run the site.pp manifest file without the initial setup configurations.

```
./bootstrap -m final.pp atomaka/feature/final
```

Run the final.pp manifest file on the ```atomaka/feature/final``` branch of the
project.
