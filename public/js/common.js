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
		$scope.title = "Yo, tititle";

		$scope.game = gameRsc.start();
		$scope.game.$promise.then(function(){
			$scope.game.attempts = [];
		});

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

			$scope.game.attempts.push(attempt);
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
				guess: {
					method: "GET",
					params: {
						action: "guess"
					}
				}
			}
		);
	});
})(window, angular);