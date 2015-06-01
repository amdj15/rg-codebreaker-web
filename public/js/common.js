(function(window, angular, undefined){
	angular.module("codebreaker", [
		'ngResource',
		'ui.router',
		'ui.bootstrap'
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

	}).controller("home", function($scope, gameRsc, $modal){
		var setStorage = function(data){
			localStorage.setItem('token', data.token);
		};

		$scope.input = {
			assemption: ''
		};

		$scope.guess = function(form) {
			if (form.$invalid) {
				return;
			}

			$scope.game.$guess({
				data: $scope.input.assemption
			}).then(function(){
				$scope.input.assemption  = '';
			});
		};

		$scope.newGame = function() {
			$scope.game.$start().then(setStorage);
		};

		$scope.hint = function() {
			$scope.game.$hint();
		};

		$scope.saveDialog = function() {
			$modal.open({
				templateUrl: '/templates/save_modal.html',
				controller: 'saveModal',
				size: 'sm',
				resolve: {
					game: function() {
						return $scope.game;
					}
				}
			});
		};

		// init game
		$scope.game = new gameRsc();

		if (localStorage.getItem('token')) {
			$scope.game.token = localStorage.getItem('token');
			$scope.game.$load().catch(function(){
				$scope.game.$start().then(setStorage);
			});
		} else {
			$scope.game.$start().then(setStorage);
		}
	}).controller('saveModal', function($scope, game, $state){
		$scope.name = '';

		$scope.save = function() {
			game.$save({
				data: $scope.name
			}).then(function(){
				$state.go('results');
				$scope.$close();
			});
		};
	}).controller("results", function($scope, resultsRsc){
		$scope.results = resultsRsc.query();
	}).factory('gameRsc', function($resource){
		return $resource(
			"/game/:action/:data",
			{
				token : "@token"
			},
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
				},
				save: {
					method: "GET",
					params: {
						action: "save"
					}
				}
			}
		);
	}).factory('resultsRsc', function($resource){
		return $resource('/results');
	});
})(window, angular);