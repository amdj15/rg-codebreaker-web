(function(window, angular, undefined){
	angular.module("codebreaker", [
		'ngResource',
		'ui.router'
	]).config(function($stateProvider, $urlRouterProvider) {
		$stateProvider.state("home", {
			url: "/",
			templateUrl: "/templates/home.html",
			controller: "home"
		}).state("results", {
			url: "/results",
			templateUrl: "/templates/results.html",
			controller: "results"
		});

		$urlRouterProvider.otherwise("/");

	}).controller("home", function($scope, gameRsc){
		var start = function() {
			$scope.game = gameRsc.start();

			$scope.game.$promise.then(function(){
				$scope.game.history = [];
				$scope.moreHints = true;

				localStorage.setItem('token', $scope.game.token);
			});

			return $scope.game.$promise;
		};

		var load = function(token) {
			$scope.game = gameRsc.load({
				token: token
			});

			$scope.game.$promise.then(function(data){
				$scope.game.token = token;
				$scope.game.history = data.history;
				$scope.game.hints = data.hints.map(function(item){ return { hint: item};});
				$scope.game.win = data.win;

				$scope.moreHints = true;
			});

			return $scope.game.$promise;
		};

		// init game
		if (localStorage.getItem('token')) {
			load(localStorage.getItem('token')).catch(function(err){
				start();
			});
		} else {
			start();
		}

		$scope.guess = function(form) {
			var attempt = gameRsc.guess({
				token: $scope.game.token,
				data: $scope.assemption
			});

			attempt.$promise.then(function(){
				$scope.assemption = '';
			}).catch(function(err){
				console.warn(err);
			});

			$scope.game.history.push(attempt);
		};

		$scope.newGame = function() {
			start();
		};

		$scope.hint = function() {
			$scope.game.hints = $scope.game.hints || [];

			gameRsc.hint({
				token: $scope.game.token
			}).$promise.then(function(data){
				if (!data.hint) {
					$scope.moreHints = false;
				}

				$scope.game.hints.push(data);
			});
		};
	}).controller("results", function($scope){

	}).factory('gameRsc',function($resource){
		return $resource(
			"/game/:action/:data",
			{},
			{
				start: {
					method: "GET",
					params: {
						action: "start"
					}
				},
				load: {
					method: "GET",
					params: {
						action: "load"
					}
				},
				guess: {
					method: "GET",
					params: {
						action: "guess"
					}
				},
				hint: {
					method: "GET",
					params: {
						action: "hint"
					}
				}
			}
		);
	});
})(window, angular);