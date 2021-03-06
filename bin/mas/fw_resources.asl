{ include( "framework.asl" ) }

{ include( "fw_distance.asl" ) }

/////////////////////////////////
//  PERFORM_TRESHOLD_ACTION
/////////////////////////////////

+!performThresholdAction : team("ALLIED") .

/**
 * Action to do when an agent has a problem with its ammo or health.
 *
 * By default always calls for help
 *
 * <em> It's very useful to overload this plan. </em>
 *
 */
+!performThresholdAction
	<-
	?my_ammo_threshold( At );
	?my_ammo( Ar );

	?team( Myteam );
	.concat( "fieldops_", Myteam, Desiredammoteam );
	.concat( "medic_", Myteam, Desiredmedicteam );

	if ( Ar <= At ) {
		?my_position( X, Y, Z );
		if ( type( "CLASS_FIELDOPS" ) ) {
			!fw_add_task( task( 9999, "TASK_GIVE_AMMOPAKS", M, pos( X, Y, Z ), "" ) );
		} else {
			.my_team( Desiredammoteam, E1 );
			.concat( "fw_cfa(", X, ", ", Y, ", ", Z, ", ", Ar, ")", Content1 );
			.send_msg_with_conversation_id( E1, tell, Content1, "CFA" );
		}
	}

	?my_health_threshold( Ht );
	?my_health( Hr );

	if ( Hr <= Ht ) {
		?my_position( X, Y, Z );
		if ( type( "CLASS_MEDIC" ) ) {
			!fw_add_task( task( 9999, "TASK_GIVE_MEDICPAKS", M, pos( X, Y, Z ), "" ) );
		} else {
			.my_team( Desiredmedicteam, E2 );
			.concat( "fw_cfm(", X, ", ", Y, ", ", Z, ", ", Hr, ")", Content2 );
			.send_msg_with_conversation_id( E2, tell, Content2, "CFM" );
		}
	}
	.

/////////////////////////////////
//  ATENDER PETICION CALL FOR
//  AMMO (SOLO FIELDOPS)
/////////////////////////////////

// Soy Fieldops y me han pedido ayuda.
+fw_cfa( X, Y, Z, Ammo )[ source( M ) ]
	<-
	!map_13;
	if ( map_13( no ) ) {
		// Get my position.
		?my_position( Myx, Myy, Myz );
		// Get distance.
		!fw_distance( pos( X, Y, Z ), pos( Myx, Myy, Myz ) );
		?fw_distance( Dist );
		// If distance is lower than threshold.
		if ( Dist < 125 & Ammo < 30 ) {
			// Give ammo.
			if ( team("ALLIED") ) {
				!add_task( task( 2000, "TASK_GIVE_AMMOPAKS", M, pos( X, Y, Z ), "" ) );
			} else {
				!fw_add_task( task( 9999, "TASK_GIVE_AMMOPAKS", M, pos( X, Y, Z ), "" ) );
			}
			//.send(M, tell, "cfa_agree");
			.concat( "cfa_agree", Content );
			.send_msg_with_conversation_id( M, tell, Content, "CFA" );
			-+state( standing );
		} else {
			// Ingore.
			//.send(M, tell, "cfa_refuse");
			.concat("cfm_refuse", Content);
			.send_msg_with_conversation_id(M, tell, Content, "CFA");
		}
		-fw_cfa( _ )[ source( M ) ];
	} else {
		// Ingore.
		//.send(M, tell, "cfa_refuse");
		.concat("cfm_refuse", Content);
		.send_msg_with_conversation_id(M, tell, Content, "CFA");
	}
	.

/////////////////////////////////
//  ATENDER PETICION CALL FOR
//  MEDIC  (SOLO MEDICOS)
/////////////////////////////////

// Soy medico y me han pedido ayuda
+fw_cfm( X, Y, Z, Salud )[ source( M ) ]
	<-
	!map_13;
	if ( map_13( no ) ) {
		// Get my position.
		?my_position( Myx, Myy, Myz );
		// Get distance.
		!fw_distance( pos( X, Y, Z ), pos( Myx, Myy, Myz ) );
		?fw_distance( Dist );
		// If distance is lower than threshold.
		if ( Dist < 75 & Salud < 50 ) {
			// Give medpack.
			if ( team("ALLIED") ) {
				!add_task( task( 2000, "TASK_GIVE_MEDICPAKS", M, pos( X, Y, Z ), "" ) );
			} else {
				!fw_add_task( task( 9999, "TASK_GIVE_MEDICPAKS", M, pos( X, Y, Z ), "" ) );
			}
			// .send(M, tell, "cfm_agree");
			.concat( "cfm_agree", Content );
			.send_msg_with_conversation_id( M, tell, Content, "CFM" );
			-+state( standing );
		} else {
			// Ingore.
			//.send(M, tell, "cfm_refuse");
			.concat( "cfm_refuse", Content );
			.send_msg_with_conversation_id( M, tell, Content, "CFM" );
		}
		-fw_cfm( _ )[ source( M ) ];
	} else {
		// Ingore.
		//.send(M, tell, "cfm_refuse");
		.concat( "cfm_refuse", Content );
		.send_msg_with_conversation_id( M, tell, Content, "CFM" );
	}
	.

/////////////////////////////////
//  NO_RESOURCE_ACTION
/////////////////////////////////

/**
 * Action to do if this agent cannot shoot.
 *
 * This plan is called when the agent try to shoot, but has no ammo. The
 * agent will spit enemies out. :-)
 *
 * <em> It's very useful to overload this plan. </em>
 *
 */
+!perform_no_ammo_action .

/**
 * Action to do when an agent is being shot.
 *
 * This plan is called every time this agent receives a messager from
 * agent Manager informing it is being shot.
 *
 * <em> It's very useful to overload this plan. </em>
 *
 */
+!perform_injury_action .