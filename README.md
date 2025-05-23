# wobbly-weather
Weather Forecasting For The Wondering Traveler

## Approach

The approach was simple
- Create a wrapper for the OpenWeatherMap API
- Cache the results based on the name of the city
- Display the results in a pretty Bootstrapped way
- Rpsec tests the underlying code
- Use Rails provided Caching to reduce complexity of setup

### API Key

One can get a free API key from [OpenWeatherMap](https://openweathermap.org/)

Using [12 Factor App](https://12factor.net/) principals I have used [direnv](https://direnv.net/) to load environment variables. This helps with security as one does not store Env Vars in the project helping to prevent unintentional leaking of API keys.

## Assumptions

As noted in [weather_fetcher.rb](./app/services/weather_fetcher.rb) I cribbed the minimal wrapper functionality from https://medium.com/@bamnelkarvivek/how-i-made-a-simple-weather-app-in-ruby-on-rails-309cdced25aa

This is not AI generated code but code that already existed elsewhere. I saw no reason to rewrite a simple API wrapper.

## Testing Issues

As one can see from the failed GitHub Actions the tests drove me insane. I was unable to understand the reason that the `Rails.cache` operated in the way that is operating under tests. The tests cover the necessary parts of the functionality.

I spent an hour digging into the `Rails.cache` functionality as well as its operation under test and did not get anywhere. I had contemplated replacing `Rails.cache` with a Redis backed cache but decided the additional time was going to push me over the 3 hour mark and that hopefully someone on the interviewing team would be smart enough to tell me why the cache does not operate as expected under testing conditions.

Prior to this point I would have asked team members or an AI to help me understand the issue but as neither of those are available to me on this project I called enough enough.


## Cache Approach and Reasoning

In order to keep the project simple and prevent the necessity of external dependencies, I decided to use `Rails.cache` built-in functionality. This functionality is commonly used to cache partials for static content as well as allow for dynamic caching of fragments as shown in the [examples](https://guides.rubyonrails.org/caching_with_rails.html).

In a production level environment, I would consider using Redis to cache the values depending on the number of expected cities. Redis would provide a multi-server cache point without adding to the memory burden of each of the Rails servers.

## Tooling

As a good stewart of code I believe in tooling heavily. In this case use of [overcommit](https://github.com/sds/overcommit) is table stakes.
I have configured it to do the minimum things that I think a rails application should be reviewed for:
- RuboCop
- Trailing Whitespace
- Fasterer
- Reek
- Bundle Check
- Bundle Audit
- Brakeman
- Test

In a larger project I would build in Sorbet. But for this project with the time constraint I decided that the additional complexity of adding Sorbet to the project and
typing everything was outside of the scope of reasonable.

## Setup

This project can be run in a GitHub Codespace and I would suggest doing so. This will allow you to run the project without having to install any additional tooling on your local machine or mess with ruby versions.

Using `direnv` is optional. You may also explicitly set the environment variable as part
of the setup. `direnv` is preferred as it does not pollute things as well as keeping the API key out of bash history.

### Codespace Setup
- Open in a CodeSpace from the GitHub GUI.
- `bundle install`
- `sudo apt update -y && sudo apt install direnv -y`
- Follow `direnv` documentation to enable in the shell.
- `cp .envrc.example .envrc`
- Update `.envrc` with your API key
- `direnv allow` and ensure that the keys are loaded.
- Execute server with `bin/dev` as this is the easiest way to get the server running.
- CodeSpace will ask if you want to open the web page. Accept and enjoy your weather forecast.

### Local Setup
- Clone from GitHub
- Ensure that you have `ruby 3.3.4` installed and selected as your ruby version.
- `bundle install`
- Install `direnv` for your computer and activate the shell.
- `cp .envrc.example .envrc`
- Update `.envrc` with your API key
- `direnv allow` and ensure that the keys are loaded.
- Execute server with `bin/dev` as this is the easiest way to get the server running.
- Open `localhost:3000` for the web interface.