{ include( "fw_safe_pos.asl" ) }

// Given two positions, returns the euclidean distance.
// Note that this might not be the real shortest distance (walls).
// @results +fw_distance( Nx, Y, Nz )
// Usage:
/*
	!fw_distance( pos( 0, 0, 0 ), pos ( 4, 0, 3 ) );
	?fw_distance( D );
	.println( "Distance is ", D );
*/
+!fw_distance( pos( A, B, C ), pos( X, Y, Z ) )
	<-
	D = math.sqrt( ( A - X ) * ( A - X ) + ( B - Y ) * ( B - Y ) + ( C - Z ) * ( C - Z ) );
	-+fw_distance( D );
	.

+!fw_distance( pos( A, B, C ) )
	<-
	?my_position( X, Y, Z );
	!fw_distance( pos( A, B, C ), pos( X, Y, Z ) );
	.

// Given a list of agents, returns the nearest one to the agent using this plan.
// Note that this might not be the real shortest distance (walls).
// @results +fw_nearest( Agent, Position, Distance )
// Usage:
/*
	!fw_nearest( Agents, K );
	?fw_nearest( Agent, Position, Distance );
	.println( "Nearest agent is ", Agent, " who is at ", Position, " (distance ", Distance, ")"  );
*/
+!fw_nearest( Agents )
	<-
	!fw_nearest( Agents, 0 )
	.

+!fw_nearest( Agents, K )
	<-
	// Store length of list of agents.
	.length( Agents, L );
	// Retrieve my position.
	?my_position( Myx, Myy, Myz );

	// To store sorted agents.
	-+fw_nearest_aux_ordered( [] );

	// While full list is not sorted...
	while ( fw_nearest_aux_ordered( Sortedlist ) & .length( Sortedlist, Lengthsorted ) & Lengthsorted < L ) {
		// Store internal counter.
		-+fwn_aux_c( 0 );
		// Clean auxiliar belief to repeat inner loop again.
		-+fw_nearest( -1, pos( -1, -1, -1 ), 9999 );

		// While there are unchecked agents...
		while( fwn_aux_c( C ) & C < L ) {
			// Retrieve agent.
			.nth( C, Agents, Target );
			// Extract position.
			.nth( 6, Target, Targetposition );
			// Compute distance.
			!fw_distance( Targetposition );
			?fw_distance( D );
			// Get previous minimum distance.
			?fw_nearest( _, _, Prevd );
			// If new one is lower than previous and is not already sorted...
			if ( D < Prevd & not ( .member( result( Target, Targetposition, D ), Sortedlist ) ) ) {
				// Save new nearest agent.
				-+fw_nearest( Target, Targetposition, D );
			}
			// Update counter.
			-+fwn_aux_c( C + 1 );
		}

		// Get k-nearest agent.
		?fw_nearest( Targetaux, Targetpositionaux, Daux );

		// Retrieve list.
		?fw_nearest_aux_ordered( Sortedaux );
		// Prepare new list.
		.concat( Sortedaux, [ result( Targetaux, Targetpositionaux, Daux ) ], Newsortedaux );
		// Store new list.
		-+fw_nearest_aux_ordered( Newsortedaux );
	}

	// Retrieve final list.
	?fw_nearest_aux_ordered( Thesortedlist );
	// Retrieve k-nn.
	.nth( K, Thesortedlist, Knn );
	// Store it to process it.
	-+fw_nearest( Knn );
	// Extract data.
	?fw_nearest( result( Ta, Tp, Df ) );
	// Store final result.
	-+fw_nearest( Ta, Tp, Df );

	// Clean auxiliar beliefs.
	-+fwn_aux_c( 0 );
	-fwn_aux_c( 0 );
	-+fw_nearest_aux_ordered( 0 );
	-fw_nearest_aux_ordered( 0 );
	.

// Given an Agent, returns the task to follow that agent with a threshold.
//
// @results +fw_follow( Task )
//
// Usage:
/*
	!fw_follow( Agents, Threshold );
	?fw_follow( Task );
	!add_task( Task )
*/

+!fw_follow( Agent, Threshold )
	<-
	// Extract agent position.
	.nth( 6, Agent, Pos );
	-+fw_follow( Pos );
	?fw_follow( pos( Tx, Ty, Tz ) );
	-fw_follow( Pos );
	// Get my position.
	?my_position( Myx, Myy, Myz );
	// Compute current distance.
	!fw_distance( pos( Myx, Myy, Myz ), pos( Tx, Ty, Tz ) );
	?fw_distance( Previousdistance );
	// Compute desired location.
	if ( Myx > Tx ) {
		-+fw_follow_dest_x( Tx + Threshold );
	} else {
		-+fw_follow_dest_x( Tx - Threshold );
	}
	if ( Myz > Tz ) {
		-+fw_follow_dest_z( Tz + Threshold );
	} else {
		-+fw_follow_dest_z( Tz - Threshold );
	}
	// Extract desired location.
	?fw_follow_dest_x( Dx );
	?fw_follow_dest_z( Dz );
	// Clean beliefs.
	-fw_follow_dest_x( Dx );
	-fw_follow_dest_z( Dz );
	// Get nearest valid position.
	!fw_safe_pos( Dx, 0, Dz );
	?fw_safe_pos( Fx, Fy, Fz );

	// Compute new distance.
	!fw_distance( pos( Fx, Fy, Fz ), pos( Tx, Ty, Tz ) );
	?fw_distance( Newdistance );
	if ( Newdistance < Previousdistance ) {
		-fw_follow(_);
		+fw_follow( task( 3000, "TASK_FW_FOLLOW", M, pos( Fx, Fy, Fz ), "" ) );
	} else {
		// Compute desired location.
		if ( Myx > Tx ) {
			-+fw_follow_dest_x( Myx - 1 );
		} else {
			-+fw_follow_dest_x( Myx + 1 );
		}
		if ( Myz > Tz ) {
			-+fw_follow_dest_z( Myz - 1 );
		} else {
			-+fw_follow_dest_z( Myz + 1 );
		}
		// Extract desired location.
		?fw_follow_dest_x( Ddx );
		?fw_follow_dest_z( Ddz );
		// Clean beliefs.
		-fw_follow_dest_x( Ddx );
		-fw_follow_dest_z( Ddz );
		// Get nearest valid position.
		!fw_safe_pos( Ddx, 0, Ddz );
		?fw_safe_pos( Fdx, Fdy, Fdz );
		-fw_follow(_);
		+fw_follow( task( 3000, "TASK_FW_FOLLOW", M, pos( Fdx, 0, Fdz ), "" ) );
	}
	.