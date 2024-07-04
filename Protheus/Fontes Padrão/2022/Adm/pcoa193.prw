#INCLUDE "PCOA193.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'DBTREE.CH'

#Define BMPINCLUIR  	"BMPINCLUIR.PNG"
#Define BMPALTERAR 		"NOTE.PNG"
#Define BMPEXCLUIR 		"EXCLUIR.PNG"

#Define BMPCONFIRMAR 	"OK.PNG"
#Define BMPCANCELAR 	"CANCEL.PNG"

#Define BMPCOPIAR 		"S4WB005N.PNG"
#Define BMPCOLAR 		"S4WB007N.PNG"

#Define BMPPESQUISA  	"PESQUISA.PNG"
#Define BMPFILTRO	  	"FILTRO.PNG"
#Define BMPCAMPO	  	"BMPCPO.PNG"

#Define BOTAOCLASSICO 		1
#Define BOTAOFWAREA 		2

#Define NUM_ITEM Val( Left(oTree:GetCargo(),4) )
#Define SUB_ITEM Val( Right( Left(oTree:GetCargo(),8) ,4) )
#Define X_ALIAS Left( Right( oTree:GetCargo(), 8) , 3)
#Define X_RECNO Val( Right( oTree:GetCargo(), 5) )

Function PCOA193()  
Local oCjtCubo

Private lTema10		:= GetRealTheme()$"TEMAP10#MDI"

Private aDescri		:= { 	{|| Alltrim(AL1->AL1_CONFIG)+"-"+Alltrim(AL1->AL1_DESCRI) }, ;
						    {|| Alltrim(AL3->AL3_CODIGO)+"-"+Alltrim(AL3->AL3_DESCRI) }, ;
						    {|| Alltrim(AKJ->AKJ_COD)+"-"+Alltrim(AKJ->AKJ_DESCRI) } }

Private nPesqAux
Private AUXCHAVE:= ''
Private lEdicao := .F. 

AUXCHAVE:= ''

//--------------------------------------------------------------------------//
oCjtCubo := CarregaAllCubo()   //carrega informacoes dos cubos gerenciais
//--------------------------------------------------------------------------//
CriaArvore(oCjtCubo)  //monta tree com cubos gerenciais / configuracoes / tipos de bloqueio
//--------------------------------------------------------------------------//

Return

Static Function CriaArvore(oCjtCubo)
//----------------fonte--------------------------------------------------------------//
Local oFont := Def_Fonte()
//----------------Area---------------------------------------------------------------//
Local oArea	:= CriaFWArea()
//------------------Painel SideBar---------------------------------------------------//
Local oPainelSideBar  := AdicionaSideBar(oArea, STR0001) //"Cubos Gerenciais"
//------------------Adiciona Botoes para a Barra do Painel SideBar--------------------//
Local lGravou := .F.
Local aCopia := Array(3) //posicao: 1 = ALIAS  2 = MSMGET     3 = GETDADOS 
Local nRecAux

Local nX, nZ

Local oCuboLayout, oPanel_1, oPanel_2, oPanel_3

//painel_1
Local oGetAL1

//painel_2
//Local oGdAKW
Local aHeadAKW, nLenAKW, aColsAKW

//painel_3
Local oSayHTM,oScrollHTM, cSayHTM

//Explicacao do Cubo em HTML
Local oSayCuboHTM
Local oCuboHTM
Local cSayCuboHTM

//Explicacao da configuracao do Cubo em HTML
Local oSayCfgCuboHTM
Local oCfgCuboHTM
Local oPanel2_HTML
Local cSayCfgCuboHTM

//Explicacao dos tipos de bloqueios do Cubo em HTML
Local oSayTpBloqHTM
Local oBlqCuboHTM
Local oPanel3_HTML
Local cSayTpBloqHTM

// Layout 3 - Tipos de Bloqueio
Local oBlqCuboLayout
Local oPanel1_Blq
Local oPanel2_Blq
Local oGetAKJ
Local oOndeUsado
Local aOndeUsa := {}
//
Local oCuboSel, oCubo, oCuboStruct, oCuboBlq
Local nNivel := 0

Local oCjtCfgCube, oCfgCubo, oCfgDef, oCfgStru
Local nPosDesc
Local lVisual := .T.

Local bReg_Memory := { |cAlias, lGet_Incl | 	lGet_Incl := If(lGet_Incl == NIL,  .F., lGet_Incl), ;
												dbSelectArea(cAlias), ;
												RegToMemory(cAlias,lGet_Incl) }

Local bAtua_Enchoice := { |oEnch, cAlias, lGet_Incl | 	Eval(bReg_Memory,cAlias,lGet_Incl), ;
														oEnch:EnchRefreshAll() }

//o Metodo GetCargo() do objeto xtree retorna identificador do node com a seguinte estrutura
//  Posicao 1-4 : No principal eh sempre "0000" os nos internos sao numerados sequencialmente NIVEL 1 - CUBO GER
//          5-8 : No principal eh sempre "0000" (Configuracao e Tipo de Bloqueio)
												// nos filhos sao numerados sequencialmente NIVEL 2 - CFG / TP BLOQ
//          9-11 : Alias posicionado (AL1-Cubo AL3-Configuracao AKJ-Tipo de Bloqueio
//          12-16 : Recno referente ao no posicionado na arvore
//  										utilizado na execucao do bloco de codigo bPosiciona

Local bPosiciona := {|| 	dbSelectArea(X_ALIAS), dbGoto(X_RECNO) }

//recuperar dados do cubo gerencial
Local bCube_Retrieve :=	{|nX|	oCjtCubo:SetPosition(nX), ;   //posiciona no elemento nX do conjto de cubos
						    	oCuboSel := oCjtCubo:GetCube(), ;  //Seleciona o cubo posicionado
						    	oCuboStruct := oCuboSel:GetCube_Struct(), ; //recupera a estrutura do cubo
						    	cSayHTM := PcoStrucCuboHTML(oCuboStruct), ; //monta HTML com a estrutura
						    	oSayHTM:refresh(), ;                        //refresh no objeto say/html
						    	oCuboBlq := oCuboSel:GetCube_BlockTypes(), ;  //recupera dados gerais do cubo
								oCjtCfgCube := oCuboSel:GetCube_Configuration()	, ; //recupera configuracoes de cubo
								If(oCjtCfgCube == NIL, ;
									( 	x := Set_of_Cfg_Cube():New(), ;
										oCuboSel:SetCube_Configuration(x), ;
										oCjtCfgCube := oCuboSel:GetCube_Configuration() ;
									);
								, NIL),;
						    	oCubo := oCuboSel:GetCube_DataGeneral(), ;  //recupera dados gerais do cubo
						    	oCubo:SetPosition(1), ;    					//posiciona no elemento 1 
						    	oCubo:SetRecord() }                        //posiciona na base de dados AL1

Local bCfgCube_Posiciona :=	{|nZ|	oCjtCfgCube:SetPosition(nZ), ;
						    		oCfgCubo := oCjtCfgCube:GetConfig(), ;
						    		oCfgDef := oCfgCubo:GetCubeCfg_DataGeneral(), ;
                                    oCfgStru := oCfgCubo:GetCube_StructCfg(), ;
							    	oCfgDef:SetPosition(1), ;
							    	oCfgDef:SetRecord() }
							    	
Local bPco_Ver_Recno := { || X_RECNO > 0 }

Local bActionCube  := 	{|| IIf( !lEdicao , ;
							( Eval(bEstado_0), ;
							oArea:ShowLayout ( "CUBO" ), ;
							PcoSetGrade(oGdAKW, {},{3,4,5}), ;
 						  	If( Eval(bPco_Ver_Recno), ;
 						  			( 	Eval(bPosiciona), ;
 						  				Eval(bCube_Retrieve, PcoLevel1Cargo(oTree)),;
	 						  			Eval(bAtua_Enchoice, oGetAL1, "AL1"), ;
 							  			PcoAKWaCols(oCuboStruct, oGdAKW, aColsAKW) ;
 							  		), NIL);
 						  	),Nil)}

Local bActionTpBlq := 	{|| IIf( !lEdicao , ; 
							( Eval(bEstado_0), ;
							oArea:ShowLayout( "BLOQ_CUBO"), ;
							Eval(bCube_Retrieve, PcoLevel1Cargo(oTree)),;
 						  	If( Eval(bPco_Ver_Recno), ;
	 						  	( 	Eval(bPosiciona), ;
 							  	 	Eval(bAtua_Enchoice, oGetAKJ, "AKJ"), ;
 							  	 	PcoLstBox(oOndeUsado, aOndeUsa) ;
 							  	 ) ;
 						  	 	, NIL );
							),Nil)}

Local bActionConfig  := 	{|| IIf( !lEdicao , ; 
								( Eval(bEstado_0), ;
								lVisual := .T., ;
				   				oArea:ShowLayout ( "CFGCUBO" ), ;
								PcoSetGrade(oGdAL4, {},{3,4,5}), ;
								Eval(bCube_Retrieve, PcoLevel1Cargo(oTree)),;
 							  	If( Eval(bPco_Ver_Recno), ;
 						  				( 	Eval(bPosiciona), ;
											Eval(bCfgCube_Posiciona, PcoLevel2Cargo(oTree)), ;
	 						  				Eval(bAtua_Enchoice, oGetAL3, "AL3"), ;
											M->AL4_CONFIG := M->AL3_CONFIG, ;
											M->AL4_CODIGO := M->AL3_CODIGO, ;
 							  				PcoAL4aCols(oCfgStru, oGdAL4, aColsAL4) ;
	 							  		) ;
 							  		, NIL ;
 							  	) ;
							),Nil)}

Local bAvisoPosition := {|| Aviso(STR0002, STR0003, {"Ok"}) } //"Atencao"###"Acao Invalida, posicione no item correspondente. "

//--------CodeBlock para o botao incluir da barra (sidebar)-------------------------------------------------------//

Local bIncluir 		:= {|| 	cAlias := PcoAliasCargo(oTree), ;
							lGravou := PcoBtInclui( cAlias, @nRecAux ), ;
							If( lGravou .And. cAlias == "AL1", ;
								 ( PcoAddCuboTree(oTree, oCjtCubo, nRecAux, bActionCube, bExbCfgHtml, bExbTpBlHtml), ;
								 	Eval(bActionCube) ) ;
								, NIL), ;
							If( lGravou .And. cAlias == "AL3", ;
								(	PcoAddCfgTree(oTree, oCjtCfgCube, nRecAux, bActionConfig), ;
									Eval(bActionConfig) ) ;
								, NIL), ;
							If( lGravou .And. cAlias == "AKJ", ;
								( 	PcoAddBlqTree(oTree, oCuboSel, nRecAux, bActionTpBlq), ;
								  	Eval(bActionTpBlq) ) ;
								, NIL) ;
						}

Local bAlterar 		:= {|| 	cAlias := PcoAliasCargo(oTree), ;
							If( Eval(bPco_Ver_Recno), ;
								(	If( cAlias == "AL1", ;
										 ( HabEdit(oTree), Eval(bAltCubo));
										, NIL), ;
									If( cAlias == "AL3", ;
										 ( HabEdit(oTree), Eval(bAltConf));
										, NIL), ;
									If( cAlias == "AKJ", ;
										 ( HabEdit(oTree), Eval(bAltTpBloq));
										, NIL) ;
								) ;
								, Eval(bAvisoPosition) ) ;
						}

Local bExcluir 		:= {|| 	cAlias := PcoAliasCargo(oTree), ;
							If( Eval(bPco_Ver_Recno), ;
								( 	If( cAlias == "AL1", ;
										 Eval(bDelCubo);
										, NIL ), ;
									If( cAlias == "AL3", ;
										 Eval(bDelConf);
										, NIL), ;
									If( cAlias == "AKJ", ;
										 Eval(bDelTpBloq);
									, NIL) ;
								) ;
								, Eval(bAvisoPosition) ) ;
						}

Local cCargoAnt, nPosCargo, nRecPesq
Local bBuscaCargo := {|cAlias|  nPesqAux := nRecPesq, ;
								nPosCargo := aScan( oTree:aCargo, {|x| cAlias+StrZero(nPesqAux,5) $ x[1] } ), ;
								If(nPosCargo > 0, ;
										( 	oTree:TreeSeek(oTree:aCargo[nPosCargo,1]), ;
											Eval(bActionCube), ;
											dbSelectArea(cAlias), ;
											dbGoto(nRecPesq), ;
											If(cAlias == "AL3", Eval(bActionConfig), Nil), ;
											If(cAlias == "AKJ", Eval(bActionTpBlq), Nil) ;
										 ) ;
										, Help(" ",1,"PESQ01") ;
									);
							}

Local bPesquisar := {|| cCargoAnt := oTree:GetCargo(), ;
						cAlias := PcoAliasCargo(oTree),;
						dbSelectArea(cAlias), ;
						AxPesqui(), ;
						If( Found(), ;
							( nRecPesq := Recno(), Eval(bBuscaCargo, cAlias )) ;
							, oTree:TreeSeek(cCargoAnt) );
					 }

Local bCopiar 	:= {|| cAlias := PcoAliasCargo(oTree),;
						If( Eval(bPco_Ver_Recno), ;
							( 	Eval(bPosiciona), ;
								Eval(bReg_Memory, cAlias, .F.), ;
								If(cAlias == "AL1", aCopia := PcoCopiar( cAlias, oGetAL1, oGdAKW ), NIL), ;
								If(cAlias == "AL3", aCopia := PcoCopiar( cAlias, oGetAL3, oGdAL4 ), NIL), ;
								If(cAlias == "AKJ", aCopia := PcoCopiar( cAlias, oGetAKJ, NIL    ), NIL) ;
							) ;
						, Eval(bAvisoPosition) );
					 }

Local bColar 	:= {|| 	If( PcoVerCola(aCopia, PcoAliasCargo(oTree) ), ;
							Eval(bColaInc) ;
						, Eval(bAvisoPosition) );
					 }

Local bColaInc 	:= {|| 		cAlias := PcoAliasCargo(oTree), ;
							lGravou := PcoBtColar( cAlias, @nRecAux, aCopia), ;
							If( lGravou .And. cAlias == "AL1", ;
								 ( PcoAddCuboTree(oTree, oCjtCubo, nRecAux, bActionCube, bExbCfgHtml, bExbTpBlHtml), ;
								 	Eval(bActionCube) ) ;
								, NIL), ;
							If( lGravou .And. cAlias == "AL3", ;
								(	PcoAddCfgTree(oTree, oCjtCfgCube, nRecAux, bActionConfig), ;
									Eval(bActionConfig) ) ;
								, NIL), ;
							If( lGravou .And. cAlias == "AKJ", ;
								( 	PcoAddBlqTree(oTree, oCuboSel, nRecAux, bActionTpBlq), ;
								  	Eval(bActionTpBlq) ) ;
								, NIL) ;
						}



//-----------------------------------------------------------------------------------------------------//

Local oTree

Local bExbCfgHtml 	:= {|| IIf( !lEdicao , ;  	
							( Eval(bCube_Retrieve, PcoLevel1Cargo(oTree)), ;
							Eval(bReg_Memory, "AL1", .F.), ;
							oArea:ShowLayout( "CFGCUBOHTML" ); 
							),Nil)}
							
Local bExbTpBlHtml 	:= {|| IIf( !lEdicao, ;  	 
							( Eval(bCube_Retrieve, PcoLevel1Cargo(oTree)), ;
							Eval(bReg_Memory, "AL1", .F.), ;
							oArea:ShowLayout( "BLQCUBOHTML" );
							),Nil)}
							
//------------------------------------------------------------------------------------------------------//
//Estado dos Botoes original 
//PcoSetButtons(aoButtons /*array de objetos botoes*/, {1,2}/*aEnable*/, {} /*aDisable*/, {1,2} /*aShow*/, {}/*aHide*/ )

//Estado 0 - Original
Local bEstado_0 := {|| 	PcoSetButtons(aoBtSideBar, {1,2,3,4}, NIL, {1,2,3,4}, NIL ),;
						PcoSetButtons(aoBtCubo, {1,2,3}, NIL, {1,2,3}, NIL ),;
						PcoSetButtons(aoBtTxtCube, NIL, NIL, NIL, {1,2}  ),;
						PcoSetButtons(aoBtStru, {2,3}, {1,4}, {1,2,3,4}, NIL ),;
						PcoSetButtons(aoBtTxtStru, NIL, NIL, NIL, {1,2}  ),;
						PcoSetButtons(aoBtTpBlq, {1,2,3}, NIL, {1,2,3}, NIL ),;
						PcoSetButtons(aoBtTxtBlq, NIL, NIL, NIL, {1,2} ), ;
						PcoSetButtons(aoBtConf, {1,2,3}, NIL, {1,2,3}, NIL ),;
						PcoSetButtons(aoBtTxtConf, NIL, NIL, NIL, {1,2}  ),;
						PcoSetButtons(aoButCfgStru, {2,3,5}, {1,4}, {1,2,3,4,5}, NIL ),;
						PcoSetButtons(aoBtCfgStru, NIL, NIL, NIL, {1,2}  );
						 }

//Estado 1 - Quando Pressionado botao alterar do cubo gerencial
Local bEstado_1 := {|| 	PcoSetButtons(aoBtSideBar, NIL, NIL, NIL, {1,2,3,4} ),;
						PcoSetButtons(aoBtCubo, NIL, NIL, NIL, {1,2,3} ),;
						PcoSetButtons(aoBtTxtCube, NIL, NIL, {1,2}, NIL  ),;
						PcoSetButtons(aoBtStru, NIL, NIL, NIL, {1,2,3,4} ),;
						PcoSetButtons(aoBtTxtStru, NIL, NIL, NIL, {1,2} ),;
						PcoSetButtons(aoBtTpBlq, NIL, NIL, NIL, {1,2,3} ),;
						PcoSetButtons(aoBtTxtBlq, NIL, NIL, NIL, {1,2} ),;
						PcoSetButtons(aoBtConf, NIL, NIL, NIL, {1,2,3} ),;
						PcoSetButtons(aoBtTxtConf, NIL, NIL, NIL, {1,2}  ),;
						PcoSetButtons(aoButCfgStru, NIL, NIL, NIL, {1,2,3,4,5} ),;
						PcoSetButtons(aoBtCfgStru, NIL, NIL, NIL, {1,2}  );
						 }

//Estado 2 - Quando Pressionado botao alterar da estrutura do cubo gerencial
Local bEstado_2 := {|| 	PcoSetButtons(aoBtSideBar, NIL, NIL, NIL, {1,2,3,4} ),;
						PcoSetButtons(aoBtCubo, NIL, NIL, NIL, {1,2,3} ),;
						PcoSetButtons(aoBtTxtCube, NIL, NIL, NIL, {1,2}  ),;
						PcoSetButtons(aoBtStru, {3,4}, NIL, NIL, {1,2} ),;
						PcoSetButtons(aoBtTxtStru, NIL, NIL, {1,2}, NIL  ),;
						PcoSetButtons(aoBtTpBlq, NIL, NIL, NIL, {1,2,3} ),;
						PcoSetButtons(aoBtTxtBlq, NIL, NIL, NIL, {1,2} ), ;
						PcoSetButtons(aoBtConf, NIL, NIL, NIL, {1,2,3} ),;
						PcoSetButtons(aoBtTxtConf, NIL, NIL, NIL, {1,2}  ),;
						PcoSetButtons(aoButCfgStru, NIL, NIL, NIL, {1,2,3,4,5} ),;
						PcoSetButtons(aoBtCfgStru, NIL, NIL, NIL, {1,2}  );
						 }

//Estado 3 - Quando Pressionado botao alterar Tipo de Bloqueio
Local bEstado_3 := {|| 	PcoSetButtons(aoBtSideBar, NIL, NIL, NIL, {1,2,3,4} ),;
						PcoSetButtons(aoBtCubo, NIL, NIL, NIL, {1,2,3} ),;
						PcoSetButtons(aoBtTxtCube, NIL, NIL, NIL, {1,2}  ),;
						PcoSetButtons(aoBtStru, NIL, NIL, NIL, {1,2,3,4} ),;
						PcoSetButtons(aoBtTxtStru, NIL, NIL, NIL, {1,2}  ),;
						PcoSetButtons(aoBtTpBlq, NIL, NIL, NIL, {1,2,3} ),;
						PcoSetButtons(aoBtTxtBlq, {1,2}, NIL, {1,2}, NIL ), ;
						PcoSetButtons(aoBtConf, NIL, NIL, NIL, {1,2,3} ),;
						PcoSetButtons(aoBtTxtConf, NIL, NIL, NIL, {1,2}  ),;
						PcoSetButtons(aoButCfgStru, NIL, NIL, NIL, {1,2,3,4,5} ),;
						PcoSetButtons(aoBtCfgStru, NIL, NIL, NIL, {1,2}  );
						 }

//Estado 4 - Quando Pressionado botao alterar Configuracao de Cubo
Local bEstado_4 := {|| 	PcoSetButtons(aoBtSideBar, NIL, NIL, NIL, {1,2,3,4} ),;
						PcoSetButtons(aoBtCubo, NIL, NIL, NIL, {1,2,3} ),;
						PcoSetButtons(aoBtTxtCube, NIL, NIL, NIL, {1,2}  ),;
						PcoSetButtons(aoBtStru, NIL, NIL, NIL, {1,2,3,4} ),;
						PcoSetButtons(aoBtTxtStru, NIL, NIL, NIL, {1,2}  ),;
						PcoSetButtons(aoBtTpBlq, NIL, NIL, NIL, {1,2,3} ),;
						PcoSetButtons(aoBtTxtBlq, {1,2}, NIL, {1,2}, NIL ), ;
						PcoSetButtons(aoBtConf, NIL, NIL, NIL, {1,2,3} ),;
						PcoSetButtons(aoBtTxtConf, NIL, NIL, {1,2}, NIL  ),;
						PcoSetButtons(aoButCfgStru, NIL, NIL, NIL, {1,2,3,4,5} ),;
						PcoSetButtons(aoBtCfgStru, NIL, NIL, NIL, {1,2}  );
						 }

//Estado 5 - Quando Pressionado botao alterar da estrutura da Configuracao de Cubo
Local bEstado_5 := {|| 	PcoSetButtons(aoBtSideBar, NIL, NIL, NIL, {1,2,3,4} ),;
						PcoSetButtons(aoBtCubo, NIL, NIL, NIL, {1,2,3} ),;
						PcoSetButtons(aoBtTxtCube, NIL, NIL, NIL, {1,2}  ),;
						PcoSetButtons(aoBtStru, NIL, NIL, NIL, {1,2,3,4} ),;
						PcoSetButtons(aoBtTxtStru, NIL, NIL, NIL, {1,2}  ),;
						PcoSetButtons(aoBtTpBlq, NIL, NIL, NIL, {1,2,3} ),;
						PcoSetButtons(aoBtTxtBlq, {1,2}, NIL, {1,2}, NIL ), ;
						PcoSetButtons(aoBtConf, NIL, NIL, NIL, {1,2,3} ),;
						PcoSetButtons(aoBtTxtConf, NIL, NIL, NIL, {1,2}  ),;
						PcoSetButtons(aoButCfgStru, {3,4,5}, NIL,  {4,5}, {1,2} ),;
						PcoSetButtons(aoBtCfgStru, NIL, NIL, {1,2}, NIL  );
						 }

//------------------------------------------------------------------------------------------------------//

Local bAltCubo := {|| 	Eval(bEstado_1), ;
						Eval(bReg_Memory, "AL1", .F.), ;
						PcoDestroyGet(oGetAL1), ;
						INCLUI := .F. ,;
						ALTERA := .T. ,;
						EXCLUI := .F. ,;
						HabEdit(oTree) ,;
						oGetAL1 := PcoCreateGet("AL1", 4, 3, oPanel_1), ;
					}

Local bGrvCubo := {||	Eval(bEstado_0), ;
						lEdicao:= .F. ,;
						oTree:SetEnable(),;
						PcoGravAL1( .F. ), ;
						oTree:ChangePrompt(Eval(aDescri[1]), oTree:GetCargo()), ;
						PcoDestroyGet(oGetAL1), ;
						oGetAL1 := PcoCreateGet("AL1", 2, 3, oPanel_1), ;
					 }

Local bDelCubo := {|| Eval(bReg_Memory, "AL1", .F.), ;
						If( PcoCanDelCube(M->AL1_CONFIG, .T.) .And. ;
							(Aviso(STR0004,STR0005+M->AL1_CONFIG+"-"+oTree:GetPrompt()+" ?", {STR0006, STR0007} ) == 1 ),; //"Excluir Cubo"###"Confirma Exclusao do  Cubo "###"Sim"###"Nao"
							 (	PcoExcluiCubo(M->AL1_CONFIG) , ;
								oTree:DelItem());
							, NIL) ;
					}

Local bCancelCubo := {|| 	If( Aviso(STR0008,STR0009, {STR0006,STR0007})==1, ; //"Abandonar"###"Abandonar Operacao ?"###"Sim"###"Nao"
								( 	Eval(bEstado_0), ;
									lEdicao:= .F. ,;
									oTree:SetEnable(),;
									PcoDestroyGet(oGetAL1), ;
									oGetAL1 := PcoCreateGet("AL1", 2, 3, oPanel_1) ) ;
								,NIL);
						 }

//------------------------------------------------------------------------------------------------------//
Local bCancelStru := {|| 	If( Aviso(STR0008,STR0009, {STR0006,STR0007})==1, ; //"Abandonar"###"Abandonar Operacao ?"###"Sim"###"Nao"
								( Eval(bEstado_0), lEdicao:= .F. ,oTree:SetEnable(), Eval(bActionCube) ), NIL);
						 }

Local bGrvStru := {|| 	If( PcoVldAKW(oGdAKW), ;
							(	Eval(bEstado_0), ;
								lEdicao:= .F. ,;
								oTree:SetEnable(),;
								PcoGrvStru(oGdAKW, PcoRecnoCargo(oTree) , 4), ;
								PcoAtStructCubSet(oCjtCubo, PcoLevel1Cargo(oTree) ), ;
					    		oCuboStruct := oCuboSel:GetCube_Struct(), ; //recupera a estrutura do cubo
								PcoAKWaCols(oCuboStruct, oGdAKW, aColsAKW), ;						
					    		cSayHTM := PcoStrucCuboHTML(oCuboStruct), ; //monta HTML com a estrutura
				    			oSayHTM:refresh(), ;                        //refresh no objeto say/html
				    			Eval(bActionCube);
							) ;
						, NIL )  }
						
Local bDelStru := {|| 	Eval(bEstado_2) ,;
						oGdAKW:aCols[oGdAKW:nAt, Len(oGdAKW:aHeader)+1] := ! oGdAKW:aCols[oGdAKW:nAt, Len(oGdAKW:aHeader)+1] , ;
						oGdAKW:refresh(), ;
						PcoSetGrade(oGdAKW, {3,4,5}, {}) }

Local bAltStru := {|| 	Eval(bEstado_2) ,;
						M->AKW_COD := AL1->AL1_CONFIG ,;
						INCLUI := .F. ,;
						ALTERA := .T. ,;
						EXCLUI := .F. ,;
						HabEdit(oTree) ,;
						PcoSetGrade(oGdAKW, {3,4,5}, {}) }
//------------------------------------------------------------------------------------------------------//
Local bCancTpBloq	:= {|| If( Aviso(STR0008,STR0009, {STR0006,STR0007})==1, ;	
							( Eval(bEstado_0), ;
							lEdicao:= .F. ,;
							oTree:SetEnable(),;
							PcoDestroyGet(oGetAKJ) , ;
							Eval(bReg_Memory, "AKJ", .F.), ;							
							oGetAKJ := PcoCreateGet("AKJ", 2, 3, oPanel1_Blq)) ;
							, Nil)}	

Local bDelTpBloq	:= {|| Eval(bReg_Memory, "AKJ", .F.), ;
							If( PcoCanTpBloqExcl(M->AKJ_COD, .T.) .And. ;
								(Aviso(STR0010,STR0011+M->AKJ_COD+"-"+oTree:GetPrompt()+" ?", {STR0006, STR0007} ) == 1 ),; //"Excluir Tipo de Bloqueio"##"Confirma Exclusao do  Tipo de Bloqueio "##"Sim"##"Nao"
							 		(	PcoTpBlqExclui(M->AKJ_COD) , ;
										oTree:DelItem() );
							, NIL) }
							
Local bAltTpBloq	:= {|| 	Eval(bEstado_3), ;
							PcoDestroyGet(oGetAKJ) , ;
							Eval(bReg_Memory, "AKJ", .F.), ;
							INCLUI := .F. ,;
							ALTERA := .T. ,;
							EXCLUI := .F. ,;
							HabEdit(oTree) ,;
							oGetAKJ := PcoCreateGet("AKJ", 4, 3, oPanel1_Blq,,"PCOVldMrg(.T.)"), ;
						 }

Local bGrvTpBloq	:= {|| PCOVldMrg(.T.) .AND. Iif(Obrigatorio(oGetAKJ:aGets,oGetAKJ:aTela),; 
							(Eval(bEstado_0), ;
							lEdicao:= .F. ,;
							oTree:SetEnable(),;
							nRecnoAKJ := AKJ->(Recno()),PcoGravTpBloq(nRecnoAKJ, .F.), ;
							oTree:ChangePrompt(Eval(aDescri[3]), oTree:GetCargo()), ;
							PcoDestroyGet(oGetAKJ), ;
							oGetAKJ := PcoCreateGet("AKJ", 2, 3, oPanel1_Blq,,"PCOVldMrg(.T.)"),),.F.) ;
					 	}

Local bSugCpo := {|| a190Suges(oGdAKW) }

//------------------------------------------------------------------------------------------------------//
Local aMenu := {}
Local oMenuTree

Local aoBtSideBar
Local aButtons 		:= {}

Local aoBtCubo
Local aButCube := {}

Local aoBtTxtCube
Local aBtTxtCube := {}

Local aoBtStru
Local aButStru := {}

Local aBtTxtStru := {}
Local aoBtTxtStru 

Local aoBtTpBlq
Local aButTpBlq := {}

Local aBtTxtBlq := {}
Local aoBtTxtBlq
//--------------------------------------------------------------------------------//
Local oConfLayout
Local oPanel1_Cfg
Local oPanel2_Cfg

Local aButConf := {}
Local aoBtConf

Local aBtTxtConf := {}
Local aoBtTxtConf

Local aButCfgStru := {}
Local aoButCfgStru

Local aBtCfgStru := {}
Local aoBtCfgStru

Local oGetAL3
Local aHeadAL4
Local nLenAL4
Local aColsAL4 := {}

Local bAltConf := {|| 	Eval(bEstado_4), ;
						Eval(bReg_Memory, "AL3", .F.), ;
						PcoDestroyGet(oGetAL3), ;
						INCLUI := .F. ,;
						ALTERA := .T. ,;
						EXCLUI := .F. ,;
						HabEdit(oTree) ,;
						oGetAL3 := PcoCreateGet("AL3", 4, 3, oPanel1_Cfg) ;
					}

Local bDelConf := {|| Eval(bReg_Memory, "AL3", .F.), ;
						If( PcoCfgCanDel(M->AL3_CONFIG, M->AL3_CODIGO, .T.) .And. ;
							(Aviso(STR0012,STR0013+M->AL3_CODIGO+"-"+oTree:GetPrompt()+" ?", {STR0006, STR0007} ) == 1 ),; //"Excluir Configuracao do Cubo"###"Confirma Exclusao da Configuracao do  Cubo "###"Sim"###"Nao"
							 (	PcoConfExclui(M->AL3_CONFIG, M->AL3_CODIGO) , ;
								,oTree:DelItem() );
							, NIL) ;
					}


Local bCancelConf := {|| 	If( Aviso(STR0008,STR0009, {STR0006,STR0007})==1, ; //"Abandonar"###"Abandonar Operacao ?"###"Sim"###"Nao"
								( 	Eval(bEstado_0), ;
									lEdicao:= .F. ,;
									oTree:SetEnable(),;
									PcoDestroyGet(oGetAL3), ;
									oGetAL3 := PcoCreateGet("AL3", 2, 3, oPanel1_Cfg) ) ;
								,NIL);
						 }

Local bGrvConf := {||	Eval(bEstado_0), ;
						lEdicao:= .F. ,;
						oTree:SetEnable(),;
						PcoGravAL3( .F. ), ;
						oTree:ChangePrompt(Eval(aDescri[2]), oTree:GetCargo()), ;
						PcoDestroyGet(oGetAL3), ;
						oGetAL3 := PcoCreateGet("AL3", 2, 3, oPanel1_Cfg), ;
					 }

Local bDelCfgStru := {|| 	Eval(bEstado_5) ,;
							oGdAL4:aCols[oGdAL4:nAt, Len(oGdAL4:aHeader)+1] := ! oGdAL4:aCols[oGdAL4:nAt, Len(oGdAL4:aHeader)+1] , ;
							oGdAL4:refresh(), ;
							PcoSetGrade(oGdAL4, {3,4,5}, {}) }

Local bAltCfgStru := {|| 	Eval(bEstado_5) ,;
							lVisual := .F., ;
							Eval(bReg_Memory, "AL3", .F.), ; 							
							M->AL4_CONFIG := M->AL3_CONFIG, ;
							M->AL4_CODIGO := M->AL3_CODIGO, ;
							INCLUI := .F. ,;
							ALTERA := .T. ,;
							EXCLUI := .F. ,;
							HabEdit(oTree) ,;
				 			PcoSetGrade(oGdAL4, {3,4,5}, {}) ;
				 	}

Local bPesqPad 	:= {|| 	Eval(bReg_Memory, "AL3", .F.), ; 
						M->AL4_CONFIG := M->AL3_CONFIG, ;
						PcoCfgPesq(M->AL3_CONFIG, oGdAL4)}

Local bFiltroCfg := {|| Eval(bReg_Memory, "AL3", .F.), ;
						PcoCfgFil(M->AL3_CONFIG, M->AL3_CODIGO, oGdAL4, lVisual) }

Local bCancelCfgStru := {|| 	If( Aviso(STR0008,STR0009, {STR0006,STR0007})==1, ; //"Abandonar"###"Abandonar Operacao ?"###"Sim"###"Nao"
									( Eval(bEstado_0), lEdicao:= .F. ,oTree:SetEnable(), Eval(bActionConfig) ), NIL);
						 }

Local bGrvCfgStru := {|| If( PcoVldAL4(oGdAL4), ;
								(	Eval(bEstado_0), ;
									lEdicao := .F. ,;
									oTree:SetEnable(),;
									PcoGrvCfgStru(oGdAL4, PcoRecnoCargo(oTree) , 4), ;
									PcoAtCfgStructSet(oCjtCfgCube, PcoLevel2Cargo(oTree) ), ;
									Eval(bActionConfig) ;
								 ) ;
						, NIL )  }

Private oGdAKW
Private oGdAL4

// Maximiza a tela principal
oArea:ODLG:LMAXIMIZED := .T.

//--------------------------------------------------------------------------------//
//os botoes da sidebar devem ser declarados e populados na mesma funcao que cria a arvore
aAdd(aButtons, { BMPPESQUISA	,BMPPESQUISA	,STR0014	, bPesquisar	,STR0014 }) //"Pesquisar"###"Pesquisar"
aAdd(aButtons, { BMPINCLUIR		,BMPINCLUIR		,STR0015		, bIncluir	,STR0015 }) //"Incluir"###"Incluir"
aAdd(aButtons, { BMPALTERAR		,BMPALTERAR		,STR0016		, bAlterar	,STR0016 }) //"Alterar"###"Alterar"
aAdd(aButtons, { BMPEXCLUIR		,BMPEXCLUIR		,STR0017		, bExcluir	,STR0017 }) //"Excluir"###"Excluir"
//aAdd(aButtons, { BMPPESQUISA	,BMPPESQUISA	,"Acoes Bloqueio"	, {||PCOA095( , , AL1->AL1_CONFIG, AKJ->AKJ_COD)}	,"Acoes Bloqueio" })

aoBtSideBar := 	CriaBotoes( aButtons, oPainelSideBar, 2, oArea, "P_SideBar" )

//----------------------------menu Popup----------------------------------------------//
aAdd(aMenu, { STR0015		, bIncluir , BMPINCLUIR } ) //"Incluir"
aAdd(aMenu, { STR0016		, bAlterar , BMPALTERAR } ) //"Alterar"
aAdd(aMenu, { STR0017		, bExcluir , BMPEXCLUIR } ) //"Excluir"
aAdd(aMenu, { "--------"	, NIL, NIL } )
aAdd(aMenu, { STR0018		, bCopiar  , BMPCOPIAR } ) //"Copiar"
aAdd(aMenu, { STR0019		, bColar   , BMPALTERAR } ) //"Colar"

oMenuTree := PcoCreaMnu(aMenu)

//================  LAYOUT 1 ======================================================
oArea:AddLayout ( "CUBO" )
oCuboLayout := oArea:GetLayout( "CUBO" )
   	
oArea:AddWindow( 100, If(lTema10,32,35) , "CadCubo",STR0020, 2, 3, oCuboLayout ) //"Cadastro Cubo"
oArea:AddPanel( 100 , 100, "AL1" )                                
oPanel_1 := oArea:GetPanel( "AL1" ) //Enchoice cabec cubo
oPanel_1:Align := CONTROL_ALIGN_ALLCLIENT

//--------------------------------------------------------------------------------//
//os botoes devem ser declarados e populados na mesma funcao que cria a arvore
aAdd(aButCube, { BMPINCLUIR		,BMPINCLUIR		,STR0015		, bIncluir		,STR0021 }) //"Incluir"###"Incluir Cubo"
aAdd(aButCube, { BMPALTERAR		, BMPALTERAR	, STR0016		, bAltCubo		, STR0022 }) //"Alterar"###"Alterar Cubo"
aAdd(aButCube, { BMPEXCLUIR		, BMPEXCLUIR	, STR0017		, bDelCubo 		, STR0004 }) //"Excluir"###"Excluir Cubo"

aoBtCubo := CriaBotoes(aButCube, oPanel_1, 2, oArea, "AL1")

aAdd(aBtTxtCube, { BMPCANCELAR	, BMPCANCELAR	, STR0023	, bCancelCubo	, STR0024 }) //"Cancelar"###"Cancelar Operacao"
aAdd(aBtTxtCube, { BMPCONFIRMAR	, BMPCONFIRMAR	, STR0025	, bGrvCubo		, STR0025 }) //"Confirmar"###"Confirmar"

aoBtTxtCube := CriaTxtButton(aBtTxtCube, oArea, "AL1", .T.)

//--------------------------------------------------------------------------------//
oArea:AddWindow( 100, If(lTema10,32,35) , "EstrCubo", STR0026, 3, 4, oCuboLayout ) //"Estrutura"
oArea:AddPanel( 100, 100, "AKW" )
oPanel_2 := oArea:GetPanel( "AKW" ) //Modelo2 Estrutura
oPanel_2:Align := CONTROL_ALIGN_ALLCLIENT

//--------------------------------------------------------------------------------//
//os botoes devem ser declarados e populados na mesma funcao que cria a arvore
aAdd(aButStru, { BMPINCLUIR		, BMPINCLUIR	, STR0015	, bIncluir		, STR0021 }) //"Incluir"###"Incluir Cubo"
aAdd(aButStru, { BMPALTERAR		, BMPALTERAR	, STR0016	, bAltStru		, STR0027 }) //"Alterar"###"Alterar Estrutura do Cubo"
aAdd(aButStru, { BMPEXCLUIR		, BMPEXCLUIR	, STR0017	, bDelStru 		, STR0028 }) //"Excluir"###"Excluir Estrutura do Cubo"
aAdd(aButStru, { BMPCAMPO 		, BMPCAMPO		, STR0029	, bSugCpo       , STR0030} ) //"Pre-Selec."###"Campos Pre-selecionados"

aoBtStru := CriaBotoes(aButStru, oPanel_2, 2, oArea, "AKW")

aAdd(aBtTxtStru, { BMPCANCELAR	, BMPCANCELAR	, STR0023	, bCancelStru	, STR0024 }) //"Cancelar"###"Cancelar Operacao"
aAdd(aBtTxtStru, { BMPCONFIRMAR	, BMPCONFIRMAR	, STR0025	, bGrvStru		, STR0025 }) //"Confirmar"###"Confirmar"

aoBtTxtStru := CriaTxtButton(aBtTxtStru, oArea, "AKW", .T.)

//------------------------------------------------------------------------------//

oArea:AddWindow( 100, 30 , "EstrCuboHTML", STR0031, 4, 2, oCuboLayout ) //"Detalhe da estrutura (Dimensoes)"
oArea:AddPanel( 100, 100, "AKW_HTML" )
oPanel_3 := oArea:GetPanel( "AKW_HTML" )
oPanel_3:Align := CONTROL_ALIGN_ALLCLIENT

//cria enchoice do cubo gerencial
dbSelectArea("AL1")
oGetAL1:= PcoCreateGet("AL1", 2, 3, oPanel_1)

//------------------------------------------------------------------------------------------//
//Cria GetDados da estrutura do cubo gerencial
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aHeader do AKW                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("AKW")
	
aHeadAKW := GetaHeader("AKW",,{"AKW_CONFIG"},{})
nLenAKW  := Len(aHeadAKW) + 1
nPosCod := Ascan(aHeadAKW, {|x| Upper(AllTrim(x[2])) == "AKW_COD" })
If nPosCod > 0
	aHeadAKW[nPosCod, 12] := "AL1->AL1_CONFIG"
EndIf	
nPosNiv := Ascan(aHeadAKW, {|x| Upper(AllTrim(x[2])) == "AKW_NIVEL" })
If nPosNiv > 0
	aHeadAKW[nPosNiv, 06] += " .AND. PcoInaCols(oGdAKW:aCols,Ascan(oGdAKW:aHeader, {|x| Upper(AllTrim(x[2])) == 'AKW_NIVEL' }),oGdAKW:nAt)"
EndIf	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aCols do AKW                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aColsAKW := {}
AAdd(aColsAKW,Array( nLenAKW ))
aColsAKW[Len(aColsAKW)][nLenAKW] := .F.
oGdAKW:= PcoGetDadosCreate(oPanel_2, aHeadAKW, aColsAKW,"+AKW_NIVEL")

//------------------------------------------------------------------------------------------//
//cria objeto oSay com conteudo da variavel cSay em HTML	
oScrollHTM := TScrollBox():New( oPanel_3 , 000, 000, 140, 280,.T.,.T.,.T.)
oScrollHTM:Align := CONTROL_ALIGN_ALLCLIENT
@ 1,1 SAY oSayHTM VAR cSayHTM OF oScrollHTM FONT oPanel_3:oFont PIXEL SIZE 700,200 HTML 

//------------------------------------------------------------------------------------------------//
cSayCuboHTM := PcoCuboHTML()
oArea:AddLayout ( "CUBOHTML" )
oCuboHTM := oArea:GetLayout ( "CUBOHTML" )
   	
oArea:AddWindow( 100, If(lTema10,94,100) , "","", 5, 5, oCuboHTM )
oArea:AddPanel( 100 , 100, "AL1_HTML" )                                
oPanel1_HTML	:= oArea:GetPanel ( "AL1_HTML" )

@ 0,0 SAY oSayCuboHTM VAR cSayCuboHTM OF oPanel1_HTML FONT oPanel1_HTML:oFont PIXEL HTML
oSayCuboHTM:Align := CONTROL_ALIGN_ALLCLIENT
//========================================================================================
oArea:AddLayout ( "CFGCUBO" )
oConfLayout := oArea:GetLayout( "CFGCUBO" )
   	
oArea:AddWindow( 100, If(lTema10,47,50), "CfgCubo",STR0032, 2, 3, oConfLayout ) //"Cadastro Configuracao de Cubo"
oArea:AddPanel( 100 , 100, "AL3" )                                
oPanel1_Cfg := oArea:GetPanel( "AL3" ) //Enchoice cabec Conf
oPanel1_Cfg:Align := CONTROL_ALIGN_ALLCLIENT

//--------------------------------------------------------------------------------//
//os botoes devem ser declarados e populados na mesma funcao que cria a arvore
aAdd(aButConf, { BMPINCLUIR		,BMPINCLUIR		, STR0015		, bIncluir		,STR0033 }) //"Incluir"###"Incluir Conf"
aAdd(aButConf, { BMPALTERAR		, BMPALTERAR	, STR0016		, bAltConf		, STR0034 }) //"Alterar"###"Alterar Conf"
aAdd(aButConf, { BMPEXCLUIR		, BMPEXCLUIR	, STR0017		, bDelConf 		, STR0035 }) //"Excluir"###"Excluir Conf"

aoBtConf := CriaBotoes(aButConf, oPanel1_Cfg, 2, oArea, "AL3")

aAdd(aBtTxtConf, { BMPCANCELAR	, BMPCANCELAR	, STR0023	, bCancelConf	, STR0024 }) //"Cancelar"###"Cancelar Operacao"
aAdd(aBtTxtConf, { BMPCONFIRMAR	, BMPCONFIRMAR	, STR0025	, bGrvConf		, STR0025 }) //"Confirmar"###"Confirmar"

aoBtTxtConf := CriaTxtButton(aBtTxtConf, oArea, "AL3", .T.)

//--------------------------------------------------------------------------------//
oArea:AddWindow( 100, If(lTema10,47,50), "EstrConf", STR0036, 3, 4, oConfLayout ) //"Estrutura Configuracao"
oArea:AddPanel( 100, 100, "AL4" )
oPanel2_Cfg := oArea:GetPanel( "AL4" ) //Modelo2 Estrutura
oPanel2_Cfg:Align := CONTROL_ALIGN_ALLCLIENT

//--------------------------------------------------------------------------------//
//os botoes devem ser declarados e populados na mesma funcao que cria a arvore
aAdd(aButCfgStru, { BMPINCLUIR		, BMPINCLUIR	, STR0015			, bIncluir		, STR0033 }) //"Incluir"###"Incluir Conf"
aAdd(aButCfgStru, { BMPALTERAR		, BMPALTERAR	, STR0016			, bAltCfgStru	, STR0037 }) //"Alterar"###"Alterar Estrutura do Conf"
aAdd(aButCfgStru, { BMPEXCLUIR		, BMPEXCLUIR	, STR0017			, bDelCfgStru 	, STR0038 }) //"Excluir"###"Excluir Estrutura do Conf"
aAdd(aButCfgStru, { BMPPESQUISA		, BMPPESQUISA	, STR0039	, bPesqPad		, STR0039} ) //"Consulta Padrao"###"Consulta Padrao"
aAdd(aButCfgStru, { BMPFILTRO 		, BMPFILTRO		, STR0040		, bFiltroCfg		, STR0041} ) //"Filtro"###"Configurar Filtro"

aoButCfgStru := CriaBotoes(aButCfgStru, oPanel2_Cfg, 2, oArea, "AL4")

aAdd(aBtCfgStru, { BMPCANCELAR	, BMPCANCELAR	, STR0023	, bCancelCfgStru	, STR0024 }) //"Cancelar"###"Cancelar Operacao"
aAdd(aBtCfgStru, { BMPCONFIRMAR	, BMPCONFIRMAR	, STR0025	, bGrvCfgStru		, STR0025 }) //"Confirmar"###"Confirmar"

aoBtCfgStru := CriaTxtButton(aBtCfgStru, oArea, "AL4", .T.)

dbSelectArea("AL3")
oGetAL3:= PcoCreateGet("AL3", 2, 3, oPanel1_Cfg)

//------------------------------------------------------------------------------------------//
//Cria GetDados da estrutura do Conf gerencial
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aHeader do AL4                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("AL4")
	
aHeadAL4 := GetaHeader("AL4",,{"AL4_CONFIG"},{})
nLenAL4  := Len(aHeadAL4) + 1

nPosDesc := Ascan(aHeadAL4, {|x| Upper(AllTrim(x[2])) == "AL4_DESCRI" })
If nPosDesc > 0
	aHeadAL4[nPosDesc, 12] := "M->AL3_DESCRI"
EndIf
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aCols do AL4                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

M->AL4_CONFIG := Space(TamSx3("AL4_CONFIG")[1])
M->AL4_CODIGO := Space(TamSx3("AL4_CODIGO")[1])

aColsAL4 := {}
AAdd(aColsAL4,Array( nLenAL4 ))
aColsAL4[Len(aColsAL4)][nLenAL4] := .F.
oGdAL4:= PcoGetDadosCreate(oPanel2_Cfg, aHeadAL4, aColsAL4)

//------------------------------------------------------------------------------------------//

//Explicacao da configuracao do Cubo em HTML
cSayCfgCuboHTM := PcoCfgCuboHTML()
oArea:AddLayout ( "CFGCUBOHTML" )
oCfgCuboHTM := oArea:GetLayout ( "CFGCUBOHTML" )
   	
oArea:AddWindow( 100, If(lTema10,94,100) , "","", 6, 6, oCfgCuboHTM )
oArea:AddPanel( 100 , 100, "AL3_HTML" )                                
oPanel2_HTML	:= oArea:GetPanel ( "AL3_HTML" )

@ 0,0 SAY oSayCfgCuboHTM VAR cSayCfgCuboHTM OF oPanel2_HTML FONT oPanel2_HTML:oFont PIXEL HTML
oSayCfgCuboHTM:Align := CONTROL_ALIGN_ALLCLIENT
//------------------------------------------------------------------------------------------------//
//Explicacao dos tipos de bloqueios do Cubo em HTML

cSayTpBloqHTM := PcoBlqCuboHTML()
oArea:AddLayout ( "BLQCUBOHTML" )
oBlqCuboHTM := oArea:GetLayout ( "BLQCUBOHTML" )
   	
oArea:AddWindow( 100, If(lTema10,94,100) , "","", 7, 7, oBlqCuboHTM )
oArea:AddPanel( 100 , 100, "AKJ_HTML" )                                
oPanel3_HTML	:= oArea:GetPanel ( "AKJ_HTML" )

@ 0,0 SAY oSayTpBloqHTM VAR cSayTpBloqHTM OF oPanel3_HTM FONT oPanel3_HTM:oFont PIXEL HTML
oSayTpBloqHTM:Align := CONTROL_ALIGN_ALLCLIENT

//================  LAYOUT 3 ======================================================
oArea:AddLayout( "BLOQ_CUBO" )
oBlqCuboLayout := oArea:GetLayout( "BLOQ_CUBO" )
   	
oArea:AddWindow( 100, If(lTema10,47,50), "BloqCubo",STR0042, 8, 9, oBlqCuboLayout ) //"Cadastro Tipos de Bloqueios Cubo"
oArea:AddPanel( 100 , 100, "AKJ" )                                
//--------------------------------------------------------------------------------//
//os botoes devem ser declarados e populados na mesma funcao que cria a arvore
aAdd(aButTpBlq, { BMPINCLUIR		, BMPINCLUIR	, STR0015		, bIncluir		, STR0043 }) //"Incluir"###"Incluir Tipo de Bloqueio"
aAdd(aButTpBlq, { BMPALTERAR		, BMPALTERAR	, STR0016		, bAltTpBloq	, STR0044 }) //"Alterar"###"Alterar Tipo de Bloqueio"
aAdd(aButTpBlq, { BMPEXCLUIR		, BMPEXCLUIR	, STR0017		, bDelTpBloq	, STR0010 }) //"Excluir"###"Excluir Tipo de Bloqueio"

aoBtTpBlq := CriaBotoes(aButTpBlq, oPanel1_Blq, 2, oArea, "AKJ")

aAdd(aBtTxtBlq, { BMPCANCELAR	, BMPCANCELAR	, STR0023	, bCancTpBloq	, STR0024 }) //"Cancelar"###"Cancelar Operacao"
aAdd(aBtTxtBlq, { BMPCONFIRMAR	, BMPCONFIRMAR	, STR0025	, bGrvTpBloq	, STR0025 }) //"Confirmar"###"Confirmar"

aoBtTxtBlq := CriaTxtButton(aBtTxtBlq, oArea, "AKJ", .T.)

//--------------------------------------------------------------------------------//
oArea:AddWindow( 100, If(lTema10,47,50), "BloqUsado", STR0045, 9, 8, oBlqCuboLayout ) //"Onde e Usado ?"
oArea:AddPanel( 100, 100, "AK8" )

oPanel1_Blq := oArea:GetPanel( "AKJ" )
oPanel2_Blq := oArea:GetPanel( "AK8" )

oPanel1_Blq:Align := CONTROL_ALIGN_ALLCLIENT
oPanel2_Blq:Align := CONTROL_ALIGN_ALLCLIENT

//cria enchoice dos tipos de bloqueio do cubo gerencial
dbSelectArea("AKJ")

oGetAKJ := PcoCreateGet("AKJ", 2, 3, oPanel1_Blq)
oGetAKJ:Disable()

oOndeUsado	:= TWBrowse():New( 0,0,290,252,,{STR0046, "Seq.", STR0047, STR0048, STR0047},,oPanel2_Blq,,,,,,,oPanel2_Blq:oFont,,,,,.F.,,.T.,,.F.,,,) //"Processo"###"Descricao"###"Item"###"Descricao"
oOndeUsado:Align := CONTROL_ALIGN_ALLCLIENT
aOndeUsa := {{"","","","",""}}

oOndeUsado:SetArray(aOndeUsa)
oOndeUsado:bLine := {|| aOndeUsa[oOndeUsado:nAT] }

//------------------------------------------------------------------------------------------//
//CRIACAO DA ARVORE
//------------------------------------------------------------------------------------------//
oTree:= Xtree():New(000,000,000,000, oPainelSideBar)

//alinha para tomar toda a tela do PainelSideBar e cria no principal 
oTree:Align := CONTROL_ALIGN_ALLCLIENT
//no principal do cubo gerencial

oTree:AddTree	( STR0001,; //descricao do node //"Cubos Gerenciais"
					"IndicatorCheckBox", ; //bitmap fechado
					"IndicatorCheckBoxOver",; //bitmap aberto
					PcoCodeCargo( NIL, NIL, "AL1", NIL), ;  //cargo (id)
					{|| IIf( !lEdicao, oArea:ShowLayout( "CUBOHTML" ),Nil) } ; //bAction - bloco de codigo para exibir
				)                                          // html com explicacao cubo gerencial


For nX := 1 TO oCjtCubo:CountCube()

   	//Cubo Gerencial
   	Eval(bCube_Retrieve, nX)
	nNivel := 1       //primeiro nivel cubo gerencial
	oTree:AddTree 	(	Eval(aDescri[nNivel]), ;  //descricao do no
 						"PCOCUBE",;            //bitmap fechado
 						"FOLDER6", ;           //bitmap aberto
 						PcoCodeCargo( nX, NIL, "AL1", oCubo), ;  //cargo (id)
 						bActionCube/*bAction*/, ;
 						{||}/*bRClick*/, ;
 						{||}/*bDblClick*/ )

	// Configuracao do Cubo Gerencial
	oTree:AddTree	( 	STR0049, ;  	//descricao do no //"Configuracoes"
						"FILTRO", ;            //bitmap fechado
						"IndicatorCheckBoxOver", ;   //bitmap aberto
						PcoCodeCargo( nX, NIL, "AL3", NIL), ;  //cargo (id)
						bExbCfgHtml ; //bAction - bloco de codigo para exibir
					)                                          // html com explicacao configuracao cubo gerencial

	nNivel := 2
		
	For nZ := 1 TO oCjtCfgCube:CountConfig()
		Eval(bCfgCube_Posiciona, nZ)

		oTree:AddTree	( 	Eval(aDescri[nNivel]), ;  //descricao do no
							"FILTRO", ;            //bitmap fechado
							"FOLDER6", ;   //bitmap aberto
							PcoCodeCargo( nX, nZ, "AL3", oCfgDef), ;  //cargo (id)
							bActionConfig ; //bAction
						)                                          

    	//finaliza node do tree  - configuracao cubo gerencial
		oTree:EndTree()

	Next

    //finaliza node do tree  - configuracao cubo gerencial
	oTree:EndTree()

		
	//Tipo de Bloqueio por Cubo Gerencial
	nNivel := 3
	oTree:AddTree	( 	STR0050, ;  //descricao do node //"Tipos de Bloqueios"
						"CADEADO", ;             //bitmap fechado
						"IndicatorCheckBoxOver", ;  //bitmap aberto
						PcoCodeCargo( nX, NIL, "AKJ", NIL), ;  //cargo (id)
						bExbTpBlHtml ; //bAction - bloco de codigo para exibir
					)                                          // html com explicacao Tipo Bloqueio do cubo 
					
    //adiciona os nos referente ao tipo de bloqueio do cubo gerencial
	For nZ := 1 TO oCuboBlq:CountRecords()

		oCuboBlq:SetPosition(nZ)
		oCuboBlq:SetRecord()

		oTree:AddTree( 	Eval(aDescri[nNivel]), ;       //descricao do no
						"CADEADO", ;					//bitmap fechado
						"IndicatorCheckBoxOver", ;		//bitmap aberto
						PcoCodeCargo( nX, nZ, "AKJ", oCuboBlq), ;  //cargo (id)
 						bActionTpBlq/*bAction*/, ;
 						{||}/*bRClick*/, ;
 						{||}/*bDblClick*/ )

	    //encerra o tree dos tipos de Bloqueio do cubo gerencial
		oTree:EndTree()
		
	Next
	
    //encerra o tree dos tipos de Bloqueio do cubo gerencial
	oTree:EndTree()
    
    //encerra o tree do cubo gerencial
	oTree:EndTree()

Next

oTree:EndTree()

oTree:BrClicked	:= {|x,y,z| PcoActMnu( oPainelSideBar, oMenuTree, oTree, x, y, z ) }

oArea:ShowLayout ( "CUBOHTML" )

oArea:ActDialog () // Ativa o Dialog

Return

//------------------------------------------------------------------------------------------//
Static Function Def_Fonte()
Local oFont
DEFINE FONT oFont NAME "FW Microsiga" SIZE 0, -8
	
SetDefFont(oFont)
//SetStyle(2)

Return oFont

//------------------------------------------------------------------------------------------//
Static Function CriaFWArea(cTit, nBorder)
Local aScreen 		:= GetScreenRes()
Local nWStage 		:= aScreen[1]-45
Local nHStage 		:= aScreen[2]-225
Local oArea, oDlg
    
oArea := FWArea():New( 000, 000, nWStage, nHStage, oDlg, nBorder, cTit) // Inicializa a Classe FWAREA e cria o DIALOG

If nBorder == NIL
	nBorder := 6
EndIf	

oArea:CreateBorder( nBorder ) /// Cria a borda envolta de toda aplicação

Return(oArea)

//------------------------------------------------------------------------------------------//
Static Function AdicionaSideBar(oArea, cTitulo)
Local oSideBar

oArea:AddSideBar( 35, 1, "SideBar")   //metodo para adicionar sidebar no objeto FWArea()
oSideBar := oArea:GetSideBar( "SideBar" )  //Get criado --> objeto para oSideBar

//adiciona nova janela no objeto oArea dentro do container oSideBar 
oArea:AddWindow( 100, If(lTema10,94,100) , "W_SIDEBAR", cTitulo /*TituloJanela*/, 1 , 1, oSideBar )	
////adiciona painel nesta nova janela
oArea:AddPanel( 100, 100, "P_SideBar" )

oPainelSideBar := oArea:GetPanel( "P_SideBar" )  //Get criado --> objeto para oPainelSideBar   

Return(oPainelSideBar)

//------------------------------------------------------------------------------------------//
Static Function CriaBotoes(aButtons, oPanel, nTypeButton, oArea, cNamePanel)
Local aObjBt := {}
Local oBar
Local nX
Local aButtonBar
Local aResource  := {}
Local aAction := {}
Local aTitle := {}

DEFAULT nTypeButton := BOTAOCLASSICO

If nTypeButton == BOTAOCLASSICO

	DEFINE BUTTONBAR oBar SIZE 15,15 3D TOP OF oPanel
	oBar:Align := CONTROL_ALIGN_TOP

	For nX := 1 TO Len(aButtons)

		aAdd(aObjBt, TBtnBmp():NewBar( aButtons[nX,1],aButtons[nX,2],,,aButtons[nX,3], aButtons[nX,4],.T.,oBar,,,aButtons[nX,5]) )
		aObjBt[Len(aObjBt)]:cTitle := aButtons[nX,3]
		aObjBt[Len(aObjBt)]:Align := CONTROL_ALIGN_RIGHT     

	Next
	
Else
	//BOTAOFWAREA
	For nX := 1 TO Len(aButtons)	
		aAdd(aResource, aButtons[nX,1] )
		aAdd(aAction, aButtons[nX,4] )
		aAdd(aTitle, aButtons[nX,3] )	
 	Next
	aButtonBar := { aResource, aAction, aTitle }

    oArea:AddButtonBar( aButtonBar )
	aObjBt := oArea:GetButtonBar(cNamePanel)

EndIf

Return(aObjBt)

//------------------------------------------------------------------------------------------//

Static Function CriaTxtButton(aBtTxt, oArea, cPanel, lHide)
Local aBtTxtTitle := {}
Local aBtTxtAction := {}
Local aBtTxtNaoSei := {}
Local aBtHide := {}
Local aButtons 
Local oBtText 
Local nX

For nX := 1 TO Len(aBtTxt)
	aAdd(aBtTxtTitle, aBtTxt[nX, 3])
	aAdd(aBtTxtAction, aBtTxt[nX, 4])
	aAdd(aBtTxtNaoSei, aBtTxt[nX, 1])
    If lHide
    	aAdd(aBtHide, nX)
    EndIf	
Next //nX

aButtons := { aBtTxtTitle, aBtTxtAction, aBtTxtNaoSei }
oArea:AddTextButton ( aButtons )
oBtText := oArea:GetTextButton(cPanel)

If lHide
	PcoSetButtons(oBtText, NIL, NIL, NIL, aBtHide)
EndIf

Return(oBtText)	

//------------------------------------------------------------------------------------------//

Function CarregaAllCubo() 
Local nX, nZ, cChv, cChvCfg
Local oCube
Local oCubeRec
Local oCubeStr
Local oCubeCfg
Local oCfgAux
Local oCubeCfgStr
Local oCubeTpBloq
Local oCjtoCube
Local oCjtoCfg

// Crio um novo objeto Lista de Registros
oCubeRec := List_Records():New() 
oCubeRec:SetAlias("AL1")
oCubeRec:SetIndex(1)
//preenche os registros
oCubeRec:Fill_Records()

//cria novo objeto que contera a colecao do cubo gerencial
oCjtoCube := Cubes_Set():New()

For nX := 1 TO oCubeRec:CountRecords()

	oCubeRec:SetPosition(nX)
	cChv := oCubeRec:GetKeyPosition()

	//Crio um novo objeto Lista de Registros - Estrutura do Cubo Posicionado
	oCubeStr := List_Records():New() 
	oCubeStr:SetAlias("AKW")
	oCubeStr:SetIndex(1)
	oCubeStr:SetSeek_CodeBlock( {|| cChv } )
	oCubeStr:SetWhile_CodeBlock( {|| AKW_FILIAL+AKW_COD == cChv } )
	
	//preenche os registros
	oCubeStr:Fill_Records()

	//Crio um novo objeto Lista de Registros - Configuracoes para o Cubo Posicionado
	oCubeCfg := List_Records():New() 
	oCubeCfg:SetAlias("AL3")
	oCubeCfg:SetIndex(3)
	oCubeCfg:SetSeek_CodeBlock( {|| cChv } )
	oCubeCfg:SetWhile_CodeBlock( {|| AL3_FILIAL+AL3_CONFIG == cChv } )
	
	//preenche os registros
	oCubeCfg:Fill_Records()
    
    //cria novo objeto que contera as configuracoes de cubo
	oCjtoCfg := Set_of_Cfg_Cube():New()
	
	For nZ := 1 TO oCubeCfg:CountRecords()

		oCubeCfg:SetPosition(nZ)
		cChvCfg := oCubeCfg:GetKeyPosition()
		
		//Set no Objeto oCube os dados da estrutura do cubo
		oCfgAux := Configuration_Cube():New() 
		oCfgAux:SetCubeCfg_DataGeneral(oCubeCfg:CloneRecPosition())

		//Crio um novo objeto Lista de Registros - Estrutura da Configuracao para o Cubo Posicionado
		oCubeCfgStr := List_Records():New() 
		oCubeCfgStr:SetAlias("AL4")
		oCubeCfgStr:SetIndex(3)
		oCubeCfgStr:SetSeek_CodeBlock( {|| cChvCfg } )
		oCubeCfgStr:SetWhile_CodeBlock( {|| AL4_FILIAL+AL4_CONFIG+AL4_CODIGO == cChvCfg } )
		
		//preenche os registros
		oCubeCfgStr:Fill_Records()
		
		//Set no Objeto oCube os dados da estrutura do cubo 
		oCfgAux:SetCube_StructCfg(oCubeCfgStr)

        //Set no Objeto que contem a colecao de configuracoes de cubo
		oCjtoCfg:SetAddCfgCube_Set(oCfgAux)
		
    Next
    
	//Crio um novo objeto Lista de Registros - Tipos de Bloqueio para o Cubo Posicionado
	oCubeTpBloq := List_Records():New() 
	oCubeTpBloq:SetAlias("AKJ")
	oCubeTpBloq:SetIndex(3)
	oCubeTpBloq:SetSeek_CodeBlock( {|| cChv } )
	oCubeTpBloq:SetWhile_CodeBlock( {|| AKJ_FILIAL+AKJ_CONFIG == cChv } )
		
	//preenche os registros
	oCubeTpBloq:Fill_Records()

	//---------    
	//cria objeto Cubo Gerencial
	oCube := Managerial_Cubes():New()

	//Set no Objeto oCube os dados gerais do cubo 
	oCube:SetCube_DataGeneral(oCubeRec:CloneRecPosition())

	//Set no Objeto oCube os dados da estrutura do cubo 
	oCube:SetCube_Struct(oCubeStr)

	//Set no Objeto oCube os dados gerais do cubo 
	oCube:SetCube_Configuration(oCjtoCfg)

	//Set no Objeto oCube os dados dos tipos de Bloqueio para o cubo 
	oCube:SetCube_BlockTypes(oCubeTpBloq)
	//-------------	

    //Set no Objeto que contem a colecao de cubo gerencial
	oCjtoCube:SetAddCube_Set(oCube)

Next

Return oCjtoCube

Static Function PcoAddCuboTree(oTree, oCjtCubo, nRecAL1, bActionCube, bExbCfgHtml, bExbTpBlHtml) 
Local aCubeAux, nY, cCargoAux
Local lNoFilho := ( PcoRecnoCargo(oTree)==0 )

dbSelectArea("AL1")
dbGoto(nRecAL1)
aCubeAux := PcoCube_New()  //retorna 2 elementos em um array
							//[1] = Definicao Cubo    [2] = Estrutura do cubo

PcoCuboAdd(oCjtCubo, aCubeAux[1], aCubeAux[2])

nY := oCjtCubo:CountCube()
aCubeAux[1]:SetPosition(1)

cCargoAux := PcoCodeCargo( nY, NIL, "AL1", aCubeAux[1] )  //cargo (id)

oTree:AddItem(	Eval(aDescri[1]), ;
				cCargoAux, ;
				"PCOCUBE", ;
				"PCOCUBE", ;
				If(lNoFilho, 2, 1),;
				bActionCube)

oTree:TreeSeek(cCargoAux)

// Configuracao do Cubo Gerencial
oTree:AddItem(	STR0049, ;  		//descricao do no //"Configuracoes"
				PcoCodeCargo( nY, NIL, "AL3", NIL ), ;  //cargo (id) 
				"FILTRO", ;            		//bitmap fechado
				"IndicatorCheckBoxOver", ;  //bitmap aberto
				2, ;                        //no filho
				bExbCfgHtml )				//bAction - bloco de codigo para exibir
											// html com explicacao configuracao cubo gerencial

//Tipo de Bloqueio
oTree:AddItem( 	STR0050, ;  	//descricao do node //"Tipos de Bloqueios"
				PcoCodeCargo( nY, NIL, "AKJ", NIL ), ;  //cargo (id)
				"CADEADO", ;             	//bitmap fechado
				"IndicatorCheckBoxOver", ;  //bitmap aberto
				2, ;                        //no filho
				bExbTpBlHtml ) 			//bAction - bloco de codigo para exibir
				                            // html com explicacao Tipo Bloqueio do cubo 

Return

Static Function PcoCube_New()
Local oCubeAdd, oCubeStrAdd, cChv

// Crio um novo objeto Lista de Registros
oCubeAdd := List_Records():New() 
oCubeAdd:SetAlias("AL1")
oCubeAdd:SetIndex(1)

//preenche os registros
oCubeAdd:AddRecord(AL1->AL1_FILIAL+AL1->AL1_CONFIG, AL1->(Recno()))

oCubeAdd:SetPosition(1)
cChv := oCubeAdd:GetKeyPosition()

//Crio um novo objeto Lista de Registros - Estrutura do Cubo Posicionado
oCubeStrAdd := List_Records():New() 
oCubeStrAdd:SetAlias("AKW")
oCubeStrAdd:SetIndex(1)
oCubeStrAdd:SetSeek_CodeBlock( {|| cChv } )
oCubeStrAdd:SetWhile_CodeBlock( {|| AKW_FILIAL+AKW_COD == cChv } )
	
//preenche os registros
oCubeStrAdd:Fill_Records()

Return( { oCubeAdd, oCubeStrAdd } )

Static Function PcoCuboAdd(oCjtoCube, oCubeAdd, oCubeStrAdd, oCjtoCfgAdd, oTpBloqAdd)
Local oCube

//cria objeto Cubo Gerencial
oCube := Managerial_Cubes():New()

//Set no Objeto oCube os dados gerais do cubo 
oCube:SetCube_DataGeneral(oCubeAdd)

//Set no Objeto oCube os dados da estrutura do cubo 
oCube:SetCube_Struct(oCubeStrAdd)

//Set no Objeto oCube os dados gerais do cubo 
oCube:SetCube_Configuration(oCjtoCfgAdd)

//Set no Objeto oCube os dados dos tipos de Bloqueio para o cubo 
oCube:SetCube_BlockTypes(oTpBloqAdd)

//Set no Objeto que contem a colecao de cubo gerencial
oCjtoCube:SetAddCube_Set(oCube)

Return

//--------Manipulacao-e-codificacao-do--id--do--noh--do---tree ----- oTree:GetCargo()------------------//

Static Function PcoCodeCargo(nLevel_1, nLevel_2, cAlias, oLstRec)
Local cCodeCargo := ""

cCodeCargo += Pco_I_Cargo(nLevel_1)       // para codificacao do primeiro nivel

cCodeCargo += Pco_I_Cargo(nLevel_2)       // para codificacao do segundo nivel

cCodeCargo += Pco_II_Cargo(cAlias)       // para codificacao do alias

If cAlias == "AL1"
	cCodeCargo += Pco_III_Cargo(oLstRec, nLevel_1)       // para codificacao do alias
Else
	cCodeCargo += Pco_III_Cargo(oLstRec, nLevel_2)       // para codificacao do alias
EndIf	

Return(cCodeCargo)


//------------------------------------------
Static Function Pco_I_Cargo(nElem)       // para codificacao do primeiro e segundo nivel

DEFAULT nElem := 0

Return(StrZero(nElem,4))

//------------------------------------------

Static Function Pco_II_Cargo(cAlias)   // para codificacao do alias

DEFAULT cAlias := Alias()

Return(PadR(cAlias,3))

//------------------------------------------

Static Function Pco_III_Cargo(oLstRec, nElem)  // para codificacao do recno
Local nRet := 0

DEFAULT oLstRec := NIL
DEFAULT nElem  := 0

If nElem == 0 .OR. oLstRec == NIL
	nRet := 0
Else
	nRet := oLstRec:GetRecordPosition()
EndIf

Return(StrZero(nRet,5))

//------------------------------------------

Static Function PcoLevel1Cargo(oTree)
Return(NUM_ITEM)

//------------------------------------------

Static Function PcoLevel2Cargo(oTree)
Return(SUB_ITEM)

//------------------------------------------

Static Function PcoAliasCargo(oTree)
Return(X_ALIAS)

//------------------------------------------
Static Function PcoRecnoCargo(oTree)
Return(X_RECNO)

//---------------------------------------------------------------------------------------------------//

Static Function PcoAKWaCols(oCuboStruct, oGdAKW, aColsAKW)
Local nX, nZ, aAuxaCols

aColsAKW := {}

For nX := 1 TO oCuboStruct:CountRecords()
	oCuboStruct:SetPosition(nX)
	oCuboStruct:SetRecord()
	aAuxaCols := {}
	For nZ := 1 TO Len(oGdAKW:aHeader)
		If ( oGdAKW:aHeader[nZ,10] != "V") 
			aAdd( aAuxaCols, FieldGet(FieldPos(oGdAKW:aHeader[nZ, 2])) )
        Else
        	aAdd( aAuxaCols, CriaVar(oGdAKW:aHeader[nZ,2]) ) 
		EndIf   						
	Next
	aAdd(aAuxaCols, .F.)
	aAdd(aColsAKW, aClone(aAuxaCols))
Next

If Empty(aColsAKW)
	aadd(aColsAKW,Array(Len(oGdAKW:aHeader)+1))
	For nX := 1 to Len(oGdAKW:aHeader)

		If AllTrim(oGdAKW:aHeader[nX,2]) == "AKW_NIVEL"
			aColsAKW[1,nX] := StrZero(1, Len(AKW->AKW_NIVEL))
		Else	
			aColsAKW[1,nX] := CriaVar(oGdAKW:aHeader[nX,2])
		EndIf

	Next //nX
	aColsAKW[1,Len(oGdAKW:aHeader)+1] := .F.
EndIf

oGdAKW:aCols := aClone(aColsAKW)
oGdAKW:refresh()

Return

Static Function PcoVldAKW(oGdAKW)
Local nI
Local nPosField
Local cUltNivel := SuperGetMV("MV_PCONVCB",.F.,"1")
//GETMV MV_PCONVCB  0 = nao verifica
//                  1 = Verifica se Tp Saldo esta no ultimo nivel
//                  2 = Verifica se esta na estrutura (pode ser em qq nivel)

Local lTpSald 	:= .F.
Local nTotNiv	:= 1
Local nUltNiv	:= 1

Local nPosChaveR 	:= Ascan(oGdAKW:aHeader, {|x| Upper(AllTrim(x[2])) == "AKW_CHAVER" })
Local nPosNivTam 	:= Ascan(oGdAKW:aHeader, {|x| Upper(AllTrim(x[2])) == "AKW_TAMANH" })
Local nPosNivel 	:= Ascan(oGdAKW:aHeader, {|x| Upper(AllTrim(x[2])) == "AKW_NIVEL" })
Local cChaveAL1	:= ""
Local nChaveSld	:= 0
Local lRet := .T.
Local nLenaCols := 0
Local aExcaCols := {}

If isInCallStack("PCOBTINCLUI")  //na inclusao renumera todos os niveis do acols 
	nLenaCols := Len(oGdAKW:aCols)
	aExcaCols  := {}
	For nI := 1 To nLenAcols
		If oGdAKW:aCols[nI] != NIL .And. oGdAKW:aCols[nI,Len(oGdAKW:aHeader)+1] //valida somente os que nao estao deletados
			aAdd(aExcaCols, StrZero( nI, Len(AKW->AKW_NIVEL) ) )
		EndIf
	Next

    For nI := nLenaCols TO 1 Step -1
    	If Ascan( aExcaCols, StrZero( nI, Len(AKW->AKW_NIVEL) ) ) > 0
			aDel(oGdAKW:aCols, nI)
		EndIf
	Next
	aSize( oGdAKW:aCols, nLenAcols-Len(aExcaCols) )
	
	For nI := 1 To Len(oGdAKW:aCols)
		oGdAKW:aCols[nI,nPosNivel] := StrZero( nI, Len(AKW->AKW_NIVEL) )
	Next
EndIf

If Empty(Alltrim(cUltNivel))
	cUltNivel := "1"
EndIf	

For nI := 1 To Len(oGdAKW:aCols)
	If ! oGdAKW:aCols[nI,Len(oGdAKW:aHeader)+1] //valida somente os que nao estao deletados
		// Busca por campos obrigatorios que nao estejam preenchidos
		nPosField := AScanx(oGdAKW:aHeader,{|x,y| x[17] .And. Empty(oGdAKW:aCols[nI][y]) })
		If nPosField > 0
			SX2->(dbSetOrder(1))
			SX2->(MsSeek("AKW"))
			HELP("  ",1,"OBRIGAT2",,X2NOME()+CRLF+STR0051+ AllTrim(oGdAKW:aHeader[nPosField][1])+CRLF+ STR0052+Str(nI,3,0),3,1)  //" Campo : "###" Linha: "		
			lRet :=  .F.
			Exit
		EndIf
		nTotNiv := nI
		If Val(oGdAKW:aCols[nUltNiv,nPosNivel]) < Val(oGdAKW:aCols[nI,nPosNivel])
			nUltNiv := nI
		EndIf
		
		//******************************
		// Validação da chave do cubo  *
		//******************************

		cChaveAL1 += "+" + Alltrim(oGdAKW:aCols[nI][nPosChaveR])
		nChaveSld += oGdAKW:aCols[nI][nPosNivTam]
		
	EndIf	
Next nI

//************************************
// valida o tamanha da chave do cubo *
//************************************
If lRet

	//**********************************
	// Valida tamanha da chave do cubo *
	//**********************************
	cChaveAL1 := SubStr(cChaveAL1,2)
	If Len(cChaveAL1) > TamSx3("AL1_CHAVER")[1]
		Aviso(STR0125,STR0126; //"Atenção!"##"O tamanho da estrutura do Cubo Gerencial não é comportada pelo campo 'AL1_CHAVER'."
		 + CHR(13) + CHR(10) + STR0127, {STR0128})//" Caso seja necessário aumente o campo no configurador."##"OK"
		lRet := .F.	

	//***********************************
	// Valida tamanha da chave do saldo *
	//***********************************
	ElseIf nChaveSld > TamSx3("AKT_CHAVE")[1]
		Aviso(STR0125,STR0129; //"Atenção!"##"O tamanho da estrutura do Cubo Gerencial não é comportada pelos campos 'AKS_CHAVE' e 'AKT_CHAVE'."
		 + CHR(13) + CHR(10) + STR0130, {STR0131})//" Caso seja necessário aumente o campo no configurador."##"OK"
		lRet := .F.		

	//************************************
	// Confirma problemas de performance *
	//************************************
	ElseIf  nTotNiv > 7 .and. M->AL1_TPATU == "1"
	
		lRet := (Aviso(STR0125,STR0132; //"Atenção!"##"Para estruturas com mais de 7 entidades não é indicada a utilização de atualização de saldo 'On-Line' e utilização de bloqueios."
		 + CHR(13) + CHR(10) + STR0133, {STR0134,STR0135})==1) //"Deseja continuar?"##"Sim"##"Não"
	
	EndIf

EndIf

If lRet .and. cUltNivel $ "1;2"

	For nI := 1 To Len(oGdAKW:aCols)
		If ! oGdAKW:aCols[nI,Len(oGdAKW:aHeader)+1] //valida somente os que nao estao deletados
			//aqui verificar se tipo de saldo esta contido na estrutura do cubo gerencial
			If 		cUltNivel == "1"
			
					lTpSald := ( Alltrim(oGdAKW:aCols[nUltNiv, nPosChaveR]) == "AKD->AKD_TPSALD" )
					
					
			ElseIf 	cUltNivel == "2"
				//verificar se existe dimensao tipo de saldo em algum nivel 
				// GetMV MV_PCONVCB ---> 2 = Verifica se esta na estrutura (pode ser em qq nivel)
				lTpSald := ( Alltrim(oGdAKW:aCols[nI, nPosChaveR]) == "AKD->AKD_TPSALD" )
	
			EndIf
	
			If lTpSald
				Exit
			EndIf
			
		EndIf
	Next //nI

	If ! lTpSald
		Aviso(STR0002, STR0124, {"Ok"})  //"Atencao"##"O cubo gerencial nao tem a dimensao Tipo de Saldo. Verifique"
		lRet := .F.
	EndIf
	
EndIf	

Return lRet

Static Function PcoLstBox(oOndeUsado, aOndeUsa)
Local cCodTpBloq
Local cQryAKH

aOndeUsa := {}

cCodTpBloq := M->AKJ_COD

dbSelectArea("AK8")
dbSetOrder(1)

dbSelectArea("AKA")
dbSetOrder(1)

cQryAKH := "SELECT AKH_PROCES, AKH_SEQ, AKH_ITEM FROM "
cQryAKH += RetSqlName("AKH")
cQryAKH += " WHERE "
cQryAKH += " AKH_FILIAL = '" + xFilial("AKH") + "' AND "
cQryAKH += " AKH_CODBLQ = '" + cCodTpBloq + "' AND "
cQryAKH += " D_E_L_E_T_ = ' ' "

cQryAKH := ChangeQuery( cQryAKH )
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQryAKH), "TMPBLQ", .T., .T. )

dbSelectArea("TMPBLQ")
dbGoTop()
While ! Eof()
	//posicionar em AK8 - processo
	dbSelectArea("AK8")
	AK8->( dbSeek(xFilial("AK8")+TMPBLQ->AKH_PROCES) )
	
	//posicionar em AKA - itens do processo
	dbSelectArea("AKA")
	AKA->( dbSeek(xFilial("AKA")+TMPBLQ->AKH_PROCES+TMPBLQ->AKH_ITEM) )
	
	dbSelectArea("TMPBLQ")
    aAdd(aOndeUsa, { TMPBLQ->AKH_PROCES, TMPBLQ->AKH_SEQ, AK8->AK8_DESCRI, TMPBLQ->AKH_ITEM, AKA->AKA_DESCRI } )
	dbSkip()
EndDo

//fecha area
dbSelectArea("TMPBLQ")
dbCloseArea()

If Empty(aOndeUsa)
	aOndeUsa := { {"","","","","" } }
EndIf

//atualiza o list box
oOndeUsado:SetArray(aOndeUsa)
oOndeUsado:bLine := {|| aOndeUsa[oOndeUsado:nAT] }
oOndeUsado:refresh()

Return



Static Function PcoStrucCuboHTML(oCuboStruct)
Local nX, nZ
Local aInfo := { { STR0053, STR0054, STR0047, STR0055, STR0056 } } //"Cubo"###"Nivel"###"Descricao"###"Descricao Composta"###"Expressao"
Local cSayHTML

//carrega os registros do AKW
For nX := 1 TO oCuboStruct:CountRecords()
	oCuboStruct:SetPosition(nX)
	oCuboStruct:SetRecord()
   	aAdd(aInfo, {AKW->AKW_COD, AKW->AKW_NIVEL, AKW->AKW_DESCRI, AKW->AKW_CONCDE, AKW_CONCCH})
Next	

//Titulo Principal
cSayHTML := '<table cellpadding="2" cellspacing="2" border="0">'+CRLF 
cSayHTML += '<tr bgcolor="#0000aa">'

//monta cabecalho da tabela
For nX := 1 TO Len(aInfo[1])
	cSayHTML += '<th valign="top"><font color="#FFFFFF">'
	cSayHTML += aInfo[1][nX]
	cSayHTML += '</font>'
Next
cSayHTML += CRLF

//monta o corpo da tabela a partir da 2a. linha de aInfo
For nX := 2 TO Len(aInfo)	
	cSayHTML += '<tr bgcolor="#F0F0F0">'
	For nZ := 1 TO Len(aInfo[nX])
		cSayHTML += '<td valign="center">'
		cSayHTML += aInfo[nX][nZ]
	Next
	cSayHTML += CRLF
Next 
cSayHTML += '</table>'
cSayHTML += CRLF

Return(cSayHTML)

Static Function PcoCuboHTML()
Local cSayHTML
cSayHTML :=	"<H1>"
cSayHTML +=	STR0001 //"Cubos Gerenciais"
cSayHTML +=	"</H1>"
cSayHTML +=	"<br>         "
cSayHTML +=	"<FONT size=+1>"
cSayHTML +=	STR0057 //" O cubo gerencial é uma ferramenta disponibilizada pelo sistema para facilitar "
cSayHTML +=	STR0058 //" o processo de acompanhamento de lançamentos orçamentários. Um cubo determina "
cSayHTML +=	STR0059 //" a forma de acumulação dos valores lançados nas movimentações orçamentárias e "
cSayHTML +=	STR0060 //" servem para acompanhamento e comparação delas."
cSayHTML +=	STR0061 //" O ambiente SIGAPCO disponibiliza a utilização dos cubos para que o usuário "
cSayHTML +=	STR0062 //" possa registrar a forma de acompanhamento de saldos orçamentários que deseja "
cSayHTML +=	STR0063 //" utilizar com frequência. "
cSayHTML +=	"</FONT> "
cSayHTML +=	"<br>         "
cSayHTML +=	"<FONT size=+1>"
cSayHTML +=	STR0064 //" Basicamente deverao ser criadas as estruturas e as configurações para os"
cSayHTML +=	STR0065 //" cubos gerenciais, e caso se trabalhe com bloqueios cadastrar tambem os tipos de "
cSayHTML +=	STR0066 //" bloqueios necessarios."
cSayHTML +=	"</FONT> "
cSayHTML +=	"<br>         "
cSayHTML +=	"<br>         "
cSayHTML +=	"<br>         "
cSayHTML +=	"<FONT size=+1>"
cSayHTML +=	STR0067 //" Se for necessário restringir os acessos dos usuarios aos dados dos cubos, "
cSayHTML +=	STR0068 //" é possível também definir acessos de usuarios as configuracoes de cubos, "
cSayHTML +=	"</FONT> "
cSayHTML +=	"<FONT size=+1>"
cSayHTML +=	STR0069 //" habilitando o parametro MV_PCOAL1, criando por exemplo configuracoes para grupos"
cSayHTML +=	STR0070 //" de centro de custo, e definindo quais usuários podem acessar qual configuracao."
cSayHTML +=	"</FONT>"

Return(cSayHTML)

 
Static Function PcoCfgCuboHTML()
Local cSayHTML

cSayHTML :=	"<H1>"
cSayHTML +=	STR0071 //" Configuracoes de cubos "
cSayHTML +=	"</H1>"
cSayHTML +=	"<br>         "
cSayHTML +=	"<FONT size=+1>"
cSayHTML +=	STR0072 //" As configuracoes de cubos sao filtros predefinidos para serem utilizados em relatórios, "
cSayHTML +=	STR0073 //" consuiltae e bloqueios. Eles sao definidos filtrando em cada nivel do cubo com os dados "
cSayHTML +=	STR0074 //" necessários. "
cSayHTML +=	"</FONT> "
cSayHTML +=	"<br>         "
cSayHTML +=	"<FONT size=+1>"
cSayHTML +=	STR0075 //" Basicamente deverao ser criadas configuracoes para filtrar os saldos orcados "
cSayHTML +=	STR0076 //" daqueles realizados, porem nao tem nenhuma restricao da quantidade de configuracoes "
cSayHTML +=	STR0077 //" que podem ser criadas, nem nos tipos de filtros aplicados, porem e altamente "
cSayHTML +=	STR0078 //" recomendado que sejam utilizados filtros que possam ser revolvidos pelo banco "
cSayHTML +=	STR0079 //" de dados que esta sendo utilizado, "
cSayHTML +=	"</FONT> "
cSayHTML +=	"<FONT size=+1>"
cSayHTML +=	STR0080 //" se esta regra nao for seguida, é possível que a performance se veja "
cSayHTML +=	STR0081 //" extremamanete prejudicada. "
cSayHTML +=	"</FONT>"
cSayHTML +=	"<br>         "
cSayHTML +=	"<br>         "
cSayHTML +=	"<br>         "
cSayHTML +=	"<FONT size=+1>"
cSayHTML +=	STR0067 //" Se for necessário restringir os acessos dos usuarios aos dados dos cubos, "
cSayHTML +=	STR0082 //" é possível também definir acessos de usuarios as configuracoes de cubos,  "
cSayHTML +=	"</FONT> "
cSayHTML +=	"<FONT size=+1>"
cSayHTML +=	STR0083 //" habilitando o parametro MV_PCOAL3, criando por exemplo configuracoes para "
cSayHTML +=	STR0084 //" grupos de centro de custo, e definindo quais usuários podem acessar qual  "
cSayHTML +=	STR0085 //" configuracao. "
cSayHTML +=	"</FONT>"

Return(cSayHTML)

Static Function PcoBlqCuboHTML()
Local cSayHTML
cSayHTML :=	"<H1>"
cSayHTML += STR0086 //" Bloqueio de Cubos Gerenciais "
cSayHTML += "</H1>"
cSayHTML +=	"<br>         "
cSayHTML +=	"<br>         "
cSayHTML +=	"<br>         "
cSayHTML +=	"<FONT size=+1>"
cSayHTML +=	STR0087 //" O tipo de bloqueio  é utilizado para definir o tipo de apuração que o sistema "
cSayHTML +=	STR0088 //" deve considerar no bloqueio, nas regras do valor orçado (configuração "
cSayHTML +=	STR0089 //" do cubo gerencial) e as regras do valor realizado que servem de base para a "
cSayHTML +=	STR0120 //" comparação e bloqueio (quando o valor realizado superar o valor orçado). "
cSayHTML +=	" </FONT> "
cSayHTML +=	"<br>         "
cSayHTML +=	"<br>         "
cSayHTML +=	"<FONT size=+1>"
cSayHTML +=	STR0090 //"  Os bloqueios ocorrem nos processos que originam a contabilização orçamentária "
cSayHTML +=	STR0121 //"  no qual informa-se a função e detalham-se as operações, tais como: inclusão, "
cSayHTML +=	STR0123 //"  alteração e exclusão, cadastrando as expressões que definem os movimentos "
cSayHTML +=	STR0122 //"  de bloqueio."
cSayHTML +=	" </FONT> "
cSayHTML +=	"<br>         "
cSayHTML +=	"<FONT size=+1>"
cSayHTML +=	STR0091 //" Quando uma verificação de bloqueio é efetuada em determinado ponto "
cSayHTML +=	STR0092 //" de bloqueio, internamente o sistema compara as informações de um cubo "
cSayHTML +=	STR0093 //" com duas configurações diferentes."
cSayHTML +=	" </FONT> "
cSayHTML +=	"<br>         "
cSayHTML +=	"<br>         "

Return(cSayHTML)


Static Function PcoBtInclui( cAlias, nRecnoAux )
Local oGet, oWizard, NX
Local aHeadAKW, aColsAKW, nLenAKW
Local aHeadAL4, aColsAL4, nLenAL4
Local nPosCod, nPosNiv
Local lGravou := .F.
Local nPosDesc

Local aButtons := {}

Local bAtuaEnch := { |cAlias, lGet_Inclui |	lGet_Inclui := If(lGet_Inclui == NIL,  .F., lGet_Inclui), ;
												dbSelectArea(cAlias), ;
												RegToMemory(cAlias,lGet_Inclui) }
Local bPesqPad, bFiltroCfg

Local bPnlValid := {|| .T. }
//colocado estas variaveis para nao dar erro na exibicao da MSMGET
Private aTELA[0][0]
Private aGETS[0]

Private oGdAL4,oGdAKW

// manipula as variáveis públicas para permitir a alteração
INCLUI := .T.
ALTERA := .F.
EXCLUI := .F.
//Private nNivelAux := 0

If cAlias == "AL1"
	
	aAdd(aButtons, { "BMPCPO"	,"BMPCPO"	,''	,{|| a190Suges(oGdAKW) },STR0030} )  //"Campos Pre-selecionados"

	dbSelectArea("AKW")
		
	aHeadAKW := GetaHeader("AKW",,{"AKW_CONFIG"},{})
	nLenAKW  := Len(aHeadAKW) + 1
	//altera o inicializador padrao para a getdados dos campos AKW_COD / AKW_NIVEL	
	nPosCod := Ascan(aHeadAKW, {|x| Upper(AllTrim(x[2])) == "AKW_COD" })
	//nPosNiv := Ascan(aHeadAKW, {|x| Upper(AllTrim(x[2])) == "AKW_NIVEL" })
	If nPosCod > 0
		aHeadAKW[nPosCod, 12] := "M->AL1_CONFIG"
	EndIf
	nPosNiv := Ascan(aHeadAKW, {|x| Upper(AllTrim(x[2])) == "AKW_NIVEL" })
	If nPosNiv > 0
		aHeadAKW[nPosNiv, 06] += " .AND. PcoInaCols(oGdAKW:aCols,Ascan(oGdAKW:aHeader, {|x| Upper(AllTrim(x[2])) == 'AKW_NIVEL' }),oGdAKW:nAt)"
	EndIf		
	/*If nPosNiv > 0
		aHeadAKW[nPosNiv, 12] := "StrZero(nNivelAux++, Len(AKW->AKW_NIVEL))"
	EndIf*/
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do aCols do AKW                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aColsAKW := {}

	oWizard := APWizard():New(	STR0002/*<chTitle>*/,; //"Atencao" //"Atencao"
								STR0094/*<chMsg>*/, ; //"Este assistente lhe ajudara a incluir um cubo gerencial."
								STR0095/*<cTitle>*/, ;  //"Inclusao de Cubo Gerencial"
								STR0096/*<cText>*/,;  //"Voce devera preencher o formulario na tela seguinte para inclusao do cubo gerencial."
								{|| .T.}/*<bNext>*/, ;
								{|| .T.}/*<bFinish>*/,;
								/*<.lPanel.>*/, , , /*<.lNoFirst.>*/)
	oWizard:NewPanel( 	STR0097/*<chTitle>*/,;  //"Cubo Gerencial"
						STR0098/*<chMsg>*/, ;  //"Neste passo voce deverá preencher o formulario para inclusao do cubo gerencial."
						{||.T.}/*<bBack>*/, ;
						{|| If(Obrigatorio(oGet:aGets,oGet:aTela), ;
									( Eval(bAtuaEnch, "AKW", .T.), ;
										If(oGdAKW == NIL, ;
											(	oGdAKW := PcoGetDadosCreate(oWizard:oMPanel[3], aHeadAKW, aColsAKW,"+AKW_NIVEL"), ;
												PcoIncluiAcols(aHeadAKW, aColsAKW,oGdAKW);
											) ;
										, NIL),  .T. ) ;
							, .F.) }/*<bNext>*/, ;
						{||.T.}/*<bFinish>*/,;
						.T./*<.lPanel.>*/,;
					 	{||.T.}/*<bExecute>*/ )
	oWizard:NewPanel( 	STR0097/*<chTitle>*/,;  //"Cubo Gerencial"
						STR0098/*<chMsg>*/, ;  //"Neste passo voce deverá preencher o formulario para inclusao do cubo gerencial."
						{||.T.}/*<bBack>*/, ;
						{||.T.}/*<bNext>*/, ;
						{||If( PcoVldAKW(oGdAKW), ;
							(  lGravou := .T., PcoGravCubo(oGdAKW, @nRecnoAux) ,.T. ) ;
							, .F.);
						}/*<bFinish>*/,;
						.T./*<.lPanel.>*/,;
					 	{||.T.}/*<bExecute>*/ )

	Eval(bAtuaEnch, cAlias, .T. )
	oGet := PcoCreateGet("AL1",3, 3, oWizard:oMPanel[2])
	aoBt := CriaBotoes(aButtons, oWizard:oMPanel[3])
	
	oWizard:Activate( .T./*<.lCenter.>*/,;
							 {||.T.}/*<bValid>*/, ;
							 {||.T.}/*<bInit>*/, ;
							 {||.T.}/*<bWhen>*/ )

ElseIf cAlias == "AKJ"
	bPnlValid := {|| PCOVldMrg() }

	oWizard := APWizard():New(	STR0002/*<chTitle>*/,; //"Atencao" //"Atencao"
								STR0099/*<chMsg>*/, ; //"Este assistente lhe ajudara a incluir um tipo de bloqueio para o cubo gerencial."
								STR0100/*<cTitle>*/, ;  //"Inclusao de Tipo de Bloqueio para Cubo Gerencial"
								STR0101/*<cText>*/,;  //"Voce devera preencher o formulario na tela seguinte para inclusao do tipo de bloqueio para cubo gerencial."
								{|| .T.}/*<bNext>*/, ;
								{|| PCOVldMrg(.T.)}/*<bFinish>*/,;
								/*<.lPanel.>*/, , , /*<.lNoFirst.>*/)
	oWizard:NewPanel( 	STR0102/*<chTitle>*/,;  //"Tipo de Bloqueio"
						STR0103/*<chMsg>*/, ;  //"Neste passo voce deverá preencher o formulario para inclusao do tipo de bloqueio."
						{||.T.}/*<bBack>*/, ;
						{|| ( Eval(bAtuaEnch, "AKJ", .T.),  .T. ) }/*<bNext>*/, ;
						{|| PCOVldMrg(.T.) .AND. Iif(Obrigatorio(oGet:aGets,oGet:aTela), ;
									(  lGravou := .T., PcoGravTpBloq(@nRecnoAux, .T.) , .T. ) ;
								, .F.) }/*<bFinish>*/,;
						.T./*<.lPanel.>*/,;
					 	{||.T.}/*<bExecute>*/ )

	Eval(bAtuaEnch, cAlias, .T. )
	M->AKJ_CONFIG := AL1->AL1_CONFIG
	oGet := PcoCreateGet("AKJ",3, 3, oWizard:oMPanel[2],,"PCOVldMrg(.T.)")
	
	oWizard:Activate( .T./*<.lCenter.>*/,;
							 {||.T.}/*<bValid>*/, ;
							 {||.T.}/*<bInit>*/, ;
							 {||.T.}/*<bWhen>*/ )
							 							 

ElseIf cAlias == "AL3"

	bPesqPad 	:= {|| 	M->AL4_CONFIG := M->AL3_CONFIG, ;
						PcoCfgPesq(M->AL3_CONFIG, oGdAL4)}

	bFiltroCfg := {|| PcoCfgFil(M->AL3_CONFIG, M->AL3_CODIGO, oGdAL4, .F.) }

	aAdd(aButtons, { BMPPESQUISA	, BMPPESQUISA	, ''	, bPesqPad		, STR0039} ) //"Consulta Padrao"
	aAdd(aButtons, { BMPFILTRO 		, BMPFILTRO		, ''	, bFiltroCfg	, STR0041} ) //"Configurar Filtro"

	dbSelectArea("AL4")

	aHeadAL4 := GetaHeader("AL4",,{"AL4_CONFIG", "AL4_CODIGO"},{})
	nLenAL4  := Len(aHeadAL4) + 1
	//altera o inicializador padrao para a getdados dos campos AL4_COD / AL4_NIVEL	
	nPosDesc := Ascan(aHeadAL4, {|x| Upper(AllTrim(x[2])) == "AL4_DESCRI" })
	If nPosDesc > 0
		aHeadAL4[nPosDesc, 12] := "M->AL3_DESCRI"
	EndIf

	nPosNiv := Ascan(aHeadAL4, {|x| Upper(AllTrim(x[2])) == "AL4_NIVEL" })
	If nPosNiv > 0
		aHeadAL4[nPosNiv, 06] += " .AND. PcoInaCols(oGdAL4:aCols,Ascan(oGdAL4:aHeader, {|x| Upper(AllTrim(x[2])) == 'AL4_NIVEL' }),oGdAL4:nAt)"
	EndIf	
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do aCols do AL4                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aColsAL4 := {}

	oWizard := APWizard():New(	STR0002/*<chTitle>*/,; //"Atencao" //"Atencao"
								STR0104/*<chMsg>*/, ; //"Este assistente lhe ajudara a incluir uma configuracao para o cubo gerencial."
								STR0105/*<cTitle>*/, ;  //"Inclusao de Configuracao do Cubo Gerencial"
								STR0106/*<cText>*/,;  //"Voce devera preencher o formulario na tela seguinte para inclusao da configuracao do cubo gerencial."
								{|| .T.}/*<bNext>*/, ;
								{|| .T.}/*<bFinish>*/,;
								/*<.lPanel.>*/, , , /*<.lNoFirst.>*/)

	oWizard:NewPanel( 	STR0107/*<chTitle>*/,;  //"Configuracao do Cubo Gerencial"
						STR0108/*<chMsg>*/, ;  //"Neste passo voce deverá preencher o formulario para inclusao da configuracao do cubo gerencial."
						{||.T.}/*<bBack>*/, ;
						{|| If(Obrigatorio(oGet:aGets,oGet:aTela), ;
								( 	Eval(bAtuaEnch, "AL4", .T.), ;
									M->AL4_CONFIG := M->AL3_CONFIG, ;
									M->AL4_CODIGO := M->AL3_CODIGO, ;
										If(oGdAL4 == NIL, ;
											(	oGdAL4 := PcoGetDadosCreate(oWizard:oMPanel[3], aHeadAL4, aColsAL4), ;
												PcoAL4IncluiAcols(aHeadAL4, aColsAL4,oGdAL4) ;
											) ;
										, aEval( oGdAL4:aCols , {|x| x[nPosDesc]:= M->AL3_DESCRI}) ),  .T. ) ;											
							, .F.) }/*<bNext>*/, ;
						{||.T.}/*<bFinish>*/,;
						.T./*<.lPanel.>*/,;
					 	{||.T.}/*<bExecute>*/ )
						
						
	oWizard:NewPanel( 	STR0097/*<chTitle>*/,;  //"Cubo Gerencial"
						STR0098/*<chMsg>*/, ;  //"Neste passo voce deverá preencher o formulario para inclusao do cubo gerencial."
						{||.T.}/*<bBack>*/, ;
						{||.T.}/*<bNext>*/, ;
						{|| If(PcoVldAL4(oGdAL4), ;
								(  lGravou := .T., PcoGravConfig(oGdAL4, @nRecnoAux) ,.T. ) ;
								, .F.) ;
						}/*<bFinish>*/,;
						.T./*<.lPanel.>*/,;
					 	{||.T.}/*<bExecute>*/ )
	

	Eval(bAtuaEnch, cAlias, .T. )
	M->AL3_CONFIG := AL1->AL1_CONFIG
	oGet := PcoCreateGet("AL3",3, 3, oWizard:oMPanel[2])
	aoBt := CriaBotoes(aButtons, oWizard:oMPanel[3])
	
	oWizard:Activate( .T./*<.lCenter.>*/,;
							 {||bPnlValid}/*<bValid>*/, ;
							 {||.T.}/*<bInit>*/, ;
							 {||.T.}/*<bWhen>*/ )

EndIf

Return(lGravou)

Static Function PcoCreateGet(cAlias,nOpcx, nOpcao2, oWindow, lOneColumn,cTudoOk)
Local oGet
Private aTELA[0][0]
Private aGETS[0]
DEFAULT lOneColumn := .T.
DEFAULT cTudoOk := "AlwaysTrue()"

oGet := MsMGet():New(cAlias,(cAlias)->(RecNo()),nOpcx,,,,,{12,0,150,285},,nOpcao2,,,cTudoOk,oWindow,,,lOneColumn)
oGet:oBox:Align := CONTROL_ALIGN_ALLCLIENT 

Return(oGet)

Static Function PcoGetDadosCreate(oWindow, aHeadAlias,aColsAlias,cInc)
Local oGetDados

oGetDados := MsNewGetDados():New(0,0,50,70,GD_INSERT+GD_UPDATE+GD_DELETE,,,cInc,,,9999,,,,oWindow,aHeadAlias,aColsAlias)

oGetDados:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

Return(oGetDados)

Static Function PcoIncluiAcols(aHeadAKW, aColsAKW, oGetdados)
Local nX
Local nLenAKW

nLenAKW  := Len(aHeadAKW) + 1

AAdd(aColsAKW,Array( nLenAKW ))
aColsAKW[Len(aColsAKW)][nLenAKW] := .F.

For nX := 1 TO Len(aHeadAKW)
	If AllTrim(aHeadAKW[nX,2]) == "AKW_COD"
		aColsAKW[Len(aColsAKW), nX] := 	M->AL1_CONFIG
	ElseIf AllTrim(aHeadAKW[nX,2]) == "AKW_NIVEL"
		aColsAKW[Len(aColsAKW), nX] := 	StrZero(1,LEN(AKW->AKW_NIVEL))
	Else	
		aColsAKW[Len(aColsAKW), nX] := CriaVar(AllTrim(aHeadAKW[nX,2]))
	EndIf	
Next

If oGetdados != NIL
	oGetdados:aCols := aClone(aColsAKW)
	oGetdados:refresh()
EndIf

Return

Static Function PcoGravCubo(oGdAKW, nRecnoAux)

// Grava Processo
PcoGravAL1( .T. )

nRecnoAux := AL1->(Recno())
PcoGrvStru(oGdAKW, nRecnoAux, 3)

Return

Static Function PcoGrvStru(oGdAKW, nRecnoAL1, nOpcx)
Local nI, cCampo, nPosCpo
Local nX
Local cChaveR:="", cDescri:="", cCubeCode := ""
Local nPosNivel := Ascan(oGdAKW:aHeader, {|x| Upper(AllTrim(x[2])) == "AKW_NIVEL" })
local nTamNivel := TamSX3("AKW_NIVEL")[1]
Local aRecAKW
Local nPos		 := 0
Local aCols

DEFAULT nRecnoAL1 := AL1->(Recno())
DEFAULT nOpcx := 3

cCubeCode := AL1->AL1_CONFIG

dbSelectArea("AKW")
dbSetOrder(1)

aSort(oGdAKW:aCols,,, { |x, y| y[nPosNivel] > x[nPosNivel] })
aCols := oGdAKW:aCols

If nOpcx == 3       //inclusao

   aRecAKW := {}
	For nX := 1 TO Len(aCols)
		If !LinDelet(aCols[nX])
			Reclock("AKW",.T.)
			nPos++
			For nI := 1 To FCount()				
				cCampo := Upper(AllTrim(FieldName(nI)))
				nPosCpo := 	Ascan(oGdAKW:aHeader, {|x| Upper(AllTrim(x[2])) == cCampo })
		      If nPosCpo > 0
		      	If cCampo == "AKW_NIVEL"
		      		aCols[nX, nPosNivel] := STRZERO(nPos, nTamNivel)
						FieldPut(nI, aCols[nX, nPosCpo])
					Else
						FieldPut(nI, aCols[nX, nPosCpo])
					Endif
				EndIf
				
			Next nI
		
			AKW->AKW_FILIAL := xFilial("AKW")
			MsUnlock()
			aAdd(aRecAKW, {Recno() , .F.}	)
		Endif		
	Next //nX

ElseIf nOpcx == 4       //alteracao

    //Carrega os registro referente acols e se nao encontrar coloca zero (0)
    aRecAKW := {}
	For nX := 1 TO Len(aCols)
		cChvaCols := xFilial("AKW")+cCubeCode+aCols[nX, nPosNivel]
		dbSelectArea("AKW")
		
		If AKW->( dbSeek(cChvaCols) ) .And. Ascan(aRecAKW, Recno()) == 0
			aAdd(aRecAKW, {Recno() , LinDelet(aCols[nX])}	)
		Else
			aAdd(aRecAKW, {0 , LinDelet(aCols[nX])} )
		EndIf
	Next  //nX
	
	For nX := 1 TO Len(aCols)
		If aRecAKW[nX,1] == 0 .and. aRecAKW[nX,2] == .F. // Novo Registro não deletado da grid
		
			Reclock("AKW",.T.)  //inclui novo
		
		ElseIf aRecAKW[nX,1] <> 0 .and. aRecAKW[nX,2] == .F.  // Registro existente não deletado da grid
		
			dbGoto(aRecAKW[nX,1])
			Reclock("AKW",.F.)  //altera existente
		
		ElseIf aRecAKW[nX,1] <> 0 .and. aRecAKW[nX,2]  // Registro existente deletado na grid
		   
			dbGoto(aRecAKW[nX,1])
			Reclock("AKW",.F.,.T.)  //altera existente
			dbDelete()
			MsUnlock()
		
		EndIf      
		
		If !aRecAKW[nX,2] // altera ou inclui o registro	
			For nI := 1 To FCount()
			
				cCampo := Upper(AllTrim(FieldName(nI)))
				nPosCpo := 	Ascan(oGdAKW:aHeader, {|x| Upper(AllTrim(x[2])) == cCampo })
		        If nPosCpo > 0
					FieldPut(nI, aCols[nX, nPosCpo])
				EndIf
				
			Next nI
		
			AKW->AKW_FILIAL := xFilial("AKW")
			MsUnlock()
			aRecAKW[nX,1] := Recno()
			
		EndIf
	
	Next  //nX

EndIf

//varre AKW para descricao concatenada e acertar na definicao do cubo (AL1)
dbSelectArea("AKW")
dbSetOrder(1)
AKW->( dbSeek(xFilial("AKW")+cCubeCode) )
While AKW->( !Eof() ) .And. xFilial()+cCubeCode== AKW->AKW_FILIAL+AKW->AKW_COD
	If aScan(aRecAKW , {|x| x[1]==Recno()})>0
		cChaveR += "+"+AllTrim(AKW->AKW_CHAVER)
		cDescri += "+"+AllTrim(AKW->AKW_DESCRI)
	
		RecLock("AKW",.F.)
		AKW->AKW_CONCDE := Substr(cDescri,2,Len(cDescri))
		AKW->AKW_CONCCH	:= Substr(cChaveR,2,Len(cChaveR))
		MsUnlock()
   Else
		Reclock("AKW",.F.,.T.)  //Deleta registros restantes do cubo que não estão na grid
		dbDelete()
		MsUnlock()
   EndIf
	AKW->(dbSkip())
End
cChaveR := Substr(cChaveR,2,Len(cChaveR))
cDescri := Substr(cDescri,2,Len(cDescri))

dbSelectArea("AL1")
dbGoto(nRecnoAL1)

RecLock("AL1",.F.)
AL1->AL1_CONCDE 	:= cDescri
AL1->AL1_CHAVER	:= cChaveR
MsUnlock()

Return

Static Function PcoAtStructCubSet(oCjtCubo, nElemCjt )
//atualiza o Conjunto de Cubos - Estrutura do arquivo posicionado
Local oLstAKW, cChv, oCuboSel, cCubeCode

If Valtype(oCjtCubo) == "O"
	cCubeCode := AL1->AL1_CONFIG

	//Crio um novo objeto Lista de Registros - Estrutura do Cubo Posicionado
	oLstAKW := List_Records():New() 
	oLstAKW:SetAlias("AKW")
	oLstAKW:SetIndex(1)
	cChv := xFilial("AKW")+cCubeCode
	oLstAKW:SetSeek_CodeBlock( {|| cChv } )
	oLstAKW:SetWhile_CodeBlock( {|| AKW_FILIAL+AKW_COD == cChv } )
	
	//preenche os registros
	oLstAKW:Fill_Records()

	oCjtCubo:SetPosition(nElemCjt) 	//posiciona no elemento nX do conjto de cubos
	oCuboSel := oCjtCubo:GetCube()	//Seleciona o cubo posicionado
     
    oCuboSel:SetCube_Struct(oLstAKW)
	
EndIf

Return

Static Function PcoGravAL1(lInclui)
Local nI, cCampo

dbSelectArea("AL1")

// Grava Processo
Reclock("AL1",lInclui)
For nI := 1 To FCount()
	cCampo := Upper(AllTrim(FieldName(nI)))
	If cCampo == "AL1_FILIAL"
		FieldPut(nI,xFilial("AL1"))
	Else
		FieldPut(nI, &("M->" + cCampo))
	EndIf
Next nI
MsUnlock()

If lInclui
	FKCommit()
EndIf

Return

Static Function PcoSetButtons(aoButtons, aBtEnable, aBtDisable, aBtShow, aBtHide)
Local nX

DEFAULT aBtEnable := {}
DEFAULT aBtDisable := {}
DEFAULT aBtShow := {}
DEFAULT aBtHide := {}

For nX := 1 TO Len(aBtEnable)
	aoButtons[aBtEnable[nX]]:Enable()
Next

For nX := 1 TO Len(aBtDisable)
	aoButtons[aBtDisable[nX]]:Disable()
Next

For nX := 1 TO Len(aBtShow)
	aoButtons[aBtShow[nX]]:Show()
Next

For nX := 1 TO Len(aBtHide)
	aoButtons[aBtHide[nX]]:Hide()
Next

Return

Static Function PcoSetGrade(oGetDados, aOptionsEnable, aOptionsDisable)
Local nX

For nX := 1 TO Len(aOptionsEnable)
	If aOptionsEnable[nX] == 3   //inclusao
		oGetDados:lInsert := .T.
	ElseIf aOptionsEnable[nX] == 4   //alteracao
		oGetDados:lUpdate := .T.
	ElseIf aOptionsEnable[nX] == 3   //exclusao
		oGetDados:lDelete := .T.
	EndIf
Next	

For nX := 1 TO Len(aOptionsDisable)
	If aOptionsDisable[nX] == 3   //inclusao
		oGetDados:lInsert := .F.
	ElseIf aOptionsDisable[nX] == 4   //alteracao
		oGetDados:lUpdate := .F.
	ElseIf aOptionsDisable[nX] == 3   //exclusao
		oGetDados:lDelete := .F.
	EndIf
Next	

Return

Static Function PcoCanDelCube(cCodCubo, lMessage)
Local lRet := .T.
Local aArea := GetArea()
Local aAreaAL3 := AL3->(GetArea())
Local aAreaAKJ := AKJ->(GetArea())

DEFAULT cCodCubo := M->AL1_CONFIG
DEFAULT lMessage := .F.

dbSelectArea("AL3")
dbSetOrder(3)
lRet := ! AL3->( dbSeek(xFilial("AL3")+cCodCubo) )

If lRet
	dbSelectArea("AKJ")
	dbSetOrder(3)
	lRet := ! AKJ->( dbSeek(xFilial("AKJ")+cCodCubo) )
EndIf

If !lRet .And. lMessage
	Aviso(STR0002, STR0109, {"Ok"}) //"Atencao"###"Cubo nao pode ser excluido, pois existem configuracoes ou tipo de bloqueio. Verifique! "
EndIf

RestArea(aAreaAKJ)
RestArea(aAreaAL3)
RestArea(aArea)

Return(lRet)

Static Function PcoExcluiCubo(cCodCubo)

dbSelectArea("AL1")
dbSetOrder(1)

If AL1->( dbSeek(xFilial("AL1")+cCodCubo) )
	
	//deletar configuracoes e estrutura de configuracoes de cubo  AL3 / AL4
	//nao eh necessario nesta interface pois ja ha validacao se pode excluir o cubo

	//deleta tipo de bloqueio associado ao cubo AKJ
	//nao eh necessario nesta interface pois ja ha validacao se pode excluir o cubo
	
	//deleta cubos - movimentos diarios        AKT
	//movimentos diarios
	dbSelectArea("AKT")
	dbSetOrder(1)
	AKT->( dbSeek(xFilial("AKT")+cCodCubo) )
	While AKT->( ! Eof() ) .And. AKT->AKT_FILIAL+AKT->AKT_CONFIG==xFilial("AKT")+cCodCubo
		Reclock("AKT",.F.,.T.)
		dbDelete()
		MsUnlock()
		AKT->(dbSkip())
	End
	
    //estrutura do cubo
	dbSelectArea("AKW")
	dbSetOrder(1)

	If AKW->( dbSeek(xFilial("AKW")+cCodCubo) )
		//deleta estrutura do cubo
		While AKW->( ! Eof() ) .And. AKW->AKW_FILIAL+AKW->AKW_COD == xFilial("AKW")+cCodCubo
		
			dbSelectArea("AKW")
			RecLock("AKW", .F.)
			dbDelete()
			MsUnLock()

			AKW->(dbSkip())
			
		EndDo
		
	EndIf
	//cubo gerencial
	dbSelectArea("AL1")
	RecLock("AL1", .F.)
	dbDelete()
	MsUnLock()

EndIf

Return

Static Function PcoDestroyGet(oGet)

If Valtype(oGet) == "O"
	oGet:oBox:FreeChildren()
EndIf	

Return


Static Function PcoGravTpBloq(nRecnoAKJ, lInclui)
Local nI, cCampo

DEFAULT lInclui := .T.

dbSelectArea("AKJ")

// Grava Processo
Reclock("AKJ",lInclui)
For nI := 1 To FCount()
	cCampo := Upper(AllTrim(FieldName(nI)))
	If cCampo == "AKJ_FILIAL"
		FieldPut(nI,xFilial("AKJ"))
	Else
		FieldPut(nI, &("M->" + cCampo))
	EndIf
Next nI
//CAMPOS QUE SAO GRAVADOS INTERNAMENTE
AKJ->AKJ_MOEDRZ := AKJ->AKJ_MOEDPR
AKJ->AKJ_NIVRE := AKJ->AKJ_NIVPR
MsUnlock()

nRecnoAKJ := AKJ->(Recno())

If lInclui
	FKCommit()
EndIf

Return

Return



Static Function PcoAddBlqTree(oTree, oCuboSel, nRecAKJ, bActionTpBlq)

Local oCubeBlq, nY, cCargoAux, oLstRec
Local lNoFilho := ( PcoRecnoCargo(oTree)==0 )
Local nLevel1 := PcoLevel1Cargo(oTree)

dbSelectArea("AKJ")
dbSetOrder(3)

dbGoto(nRecAKJ)

oCubeBlq := oCuboSel:GetCube_BlockTypes()
If oCubeBlq == NIL
	oLstRec := List_Records():New()
	oLstRec:SetAlias("AKJ")
	oLstRec:SetIndex(3)
	oLstRec:AddRecord(&(IndexKey()), Recno())
	oCuboSel:SetCube_BlockTypes(oLstRec)
	oCubeBlq := oCuboSel:GetCube_BlockTypes()
Else
	oCubeBlq:AddRecord(&(IndexKey()), Recno())
EndIf
nY := oCubeBlq:CountRecords()
oCubeBlq:SetPosition(nY)

cCargoAux :=  PcoCodeCargo(nLevel1, nY, "AKJ", oCubeBlq) 

oTree:AddItem(	Eval(aDescri[3]), ;
				cCargoAux, ;
				"CADEADO", ;
				"CADEADO", ;
				If(lNoFilho, 2, 1),;
				bActionTpBlq)

oTree:TreeSeek(cCargoAux)

Return


Static Function PcoCanTpBloqExcl(cCodTpBloq)

Local aArea := GetArea()
Local lRet	:= .T.

dbSelectArea("AKH")
AKH->(dbSetOrder(2))
If AKH->(dbSeek(xFilial("AKH")+cCodTpBloq))
	lRet := .F.
	Aviso(STR0002, STR0137, {"Ok"}) //"Atencao"###"Tipo de Bloqueio não pode ser excluido, pois está sendo usado. Verifique!"

EndIf

RestArea(aArea)

Return lRet


Static Function PcoTpBlqExclui(cCodTpBloq)

Local aArea := GetArea()

dbSelectArea("AKJ")
dbSetOrder(1)
If AKJ->( dbSeek(xFilial("AKJ")+cCodTpBloq) )
	//primeiro deletar as regras de acao para o tipo de bloqueio AKZ
	RecLock("AKJ", .F.)
	dbDelete()
	MsUnLock()
EndIf 

RestArea(aArea)

Return

Static Function PcoCreaMnu(aMenu)
Local oMenuPop
Local nX
MENU oMenuPop POPUP
	For nX := 1 TO Len(aMenu)
		If aMenu[nX, 1] != Repl("-", 8)
			MENUITEM aMenu[nX, 1] BLOCK aMenu[nX, 2] RESOURCE  aMenu[nX, 3]
		Else	
			MENUITEM '___________________' DISABLED
		EndIf
	Next		
ENDMENU                                                                             
	
Return(oMenuPop)

Static Function PcoActMnu(oDlg,oMenu,oTree,x,y,z) 
nZ:=y
nk:= z-150
oMenu:Activate(nz,nk,oDlg)
Return


Static Function PcoAL4aCols(oConfStruct, oGdAL4, aColsAL4)
Local nX, nZ, aAuxaCols

aColsAL4 := {}

For nX := 1 TO oConfStruct:CountRecords()
	oConfStruct:SetPosition(nX)
	oConfStruct:SetRecord()
	aAuxaCols := {}
	For nZ := 1 TO Len(oGdAL4:aHeader)
		If ( oGdAL4:aHeader[nZ,10] != "V") 
			aAdd( aAuxaCols, FieldGet(FieldPos(oGdAL4:aHeader[nZ, 2])) )
        Else
        	If Alltrim(oGdAL4:aHeader[nZ,2]) == "AL4_DESCRI"
        		aAdd( aAuxaCols, M->AL3_DESCRI ) 
        	Else
   	        	aAdd( aAuxaCols, CriaVar(oGdAL4:aHeader[nZ,2]) ) 
	        EndIf
		EndIf   						
	Next
	aAdd(aAuxaCols, .F.)
	aAdd(aColsAL4, aClone(aAuxaCols))
Next

If Empty(aColsAL4)
	aadd(aColsAL4,Array(Len(oGdAL4:aHeader)+1))
	For nX := 1 to Len(oGdAL4:aHeader)
		If Alltrim(oGdAL4:aHeader[nX, 2]) == "AL4_DESCRI"
			aColsAL4[1,nX] := Space(Len(AL3->AL3_DESCRI))
		ElseIf Alltrim(oGdAL4:aHeader[nX, 2]) == "AL4_FILIAL"
			aColsAL4[1,nX] := xFilial("AL4")
		Else
			aColsAL4[1,nX] := CriaVar(oGdAL4:aHeader[nX,2])
		EndIf	
	Next //nX
	aColsAL4[1,Len(oGdAL4:aHeader)+1] := .F.
EndIf

oGdAL4:aCols := aClone(aColsAL4)
oGdAL4:refresh()

Return

Static Function PcoVldAL4(oGdAL4)
Local nI
Local nPosField

For nI := 1 To Len(oGdAL4:aCols)
	If ! oGdAL4:aCols[nI,Len(oGdAL4:aHeader)+1] //valida somente os que nao estao deletados
		// Busca por campos obrigatorios que nao estejam preenchidos
		nPosField := AScanx(oGdAL4:aHeader,{|x,y| x[17] .And. Empty(oGdAL4:aCols[nI][y]) })
		If nPosField > 0
			SX2->(MsSeek("AL4"))
			HELP("  ",1,"OBRIGAT2",,X2NOME()+CRLF+STR0051+ AllTrim(oGdAL4:aHeader[nPosField][1])+CRLF+ STR0052+Str(nI,3,0),3,1)  //" Campo : "###" Linha: "
			Return .F.
		EndIf
	EndIf	
Next nI

Return .T.

Static Function PcoGravAL3(lInclui)
Local nI, cCampo

dbSelectArea("AL3")

// Grava Processo
Reclock("AL3",lInclui)
For nI := 1 To FCount()
	cCampo := Upper(AllTrim(FieldName(nI)))
	If cCampo == "AL3_FILIAL"
		FieldPut(nI,xFilial("AL3"))
	Else
		FieldPut(nI, &("M->" + cCampo))
	EndIf
Next nI
MsUnlock()

If lInclui
	FKCommit()
EndIf

Return

Static Function PcoConfExclui(cCodCubo, cCodCfg)
//no cCodigo consta o codigo do cubo gerencial e codigo da configuracao
dbSelectArea("AL3")
dbSetOrder(3)

If AL3->( dbSeek(xFilial("AL3")+cCodCubo+cCodCfg) )
	
	dbSelectArea("AL4")
	dbSetOrder(3)

	If AL4->( dbSeek(xFilial("AL4")+cCodCubo+cCodCfg) )
	
		While AL4->(! Eof() .And. AL4_FILIAL+AL4_CONFIG+AL4_CODIGO == xFilial("AL4")+cCodCubo+cCodCfg)
		
			dbSelectArea("AL4")
			RecLock("AL4", .F.)
			dbDelete()
			MsUnLock()

			AL4->(dbSkip())
			
		EndDo
		
	EndIf
	
	dbSelectArea("AL3")
	RecLock("AL3", .F.)
	dbDelete()
	MsUnLock()

EndIf

Return


Static Function PcoCfgCanDel(cCodCubo, cCodCfg, lMessage)

Local lRet := .T.
Local aArea := GetArea()
Local aAreaAKJ := AKJ->(GetArea())

DEFAULT cCodCubo := M->AL3_CONFIG
DEFAULT cCodCfg := M->AL3_CODIGO
DEFAULT lMessage := .F.

dbSelectArea("AKJ")
dbSetOrder(3)

If AKJ->( dbSeek(xFilial("AKJ")+cCodCubo) )

	While AKJ->( ! Eof() ) .And. AKJ->AKJ_FILIAL+AKJ->AKJ_CONFIG == xFilial("AKJ")+cCodCubo 

		If AKJ->AKJ_PRVCFG == cCodCfg .OR. AKJ->AKJ_REACFG == cCodCfg
			lRet := .F.
			Exit
		EndIf
		
		AKJ->( dbSkip() )
	
	EndDo


EndIf

If !lRet .And. lMessage
	Aviso(STR0002, STR0110, {"Ok"}) //"Atencao"###"Configuracao do cubo nao pode ser excluido, pois existem tipos de bloqueio vinculado. Verifique! "
EndIf

RestArea(aAreaAKJ)
RestArea(aArea)

Return(lRet)


Function PcoCfgFil(cCodCubo, cCodCfg, oGdAL4, lVisual)
Local aArea := GetArea()
Local aAreaAKW := AKW->(GetArea())
Local nPosNiv := Ascan(oGdAL4:aHeader, {|x| Upper(AllTrim(x[2])) == "AL4_NIVEL" })
Local nPosFiltro := Ascan(oGdAL4:aHeader, {|x| Upper(AllTrim(x[2])) == "AL4_FILTER" })
Local cNivCfg

Default lVisual := .F.

cNivCfg := oGdAL4:aCols[oGdAL4:oBrowse:nAt, nPosNiv]

If !Empty(cCodCubo+cCodCfg+cNivCfg)
	dbSelectArea("AKW")
	dbSetOrder(1)
	If AKW->( dbSeek(xFilial("AKW")+cCodCubo+cNivCfg) )
		If lVisual
			M->AL4_FILTER := oGdAL4:aCols[oGdAL4:oBrowse:nAt, nPosFiltro]
			BuildExpr(AKW->AKW_ALIAS,,M->AL4_FILTER)	
		Else
			cFilter := oGdAL4:aCols[oGdAL4:oBrowse:nAt, nPosFiltro]
			oGdAL4:aCols[oGdAL4:oBrowse:nAt, nPosFiltro] := BuildExpr(AKW->AKW_ALIAS,,cFilter)
		EndIf
	EndIf
EndIf

RestArea(aAreaAKW)
RestArea(aArea)

Return 


Function PcoCfgPesq(cCodCubo, oGdAL4)
Local nLinGd := oGdAL4:oBrowse:nAt
Local nPosCpo := oGdAL4:oBrowse:ColPos()
Local nPosNiv := Ascan(oGdAL4:aHeader, {|x| Upper(AllTrim(x[2])) == "AL4_NIVEL" })
LOcal cNivel
Local aArea := GetArea()
Local aAreaAKW := AKW->(GetArea())


cNivel := oGdAL4:aCols[nLinGd, nPosNiv]

dbSelectArea("AKW")
dbSetOrder(1)

If !Empty(cCodCubo+cNivel) 
	If oGdAL4:aHeader[nPosCpo,2] == "AL4_EXPRIN" .Or. oGdAL4:aHeader[nPosCpo,2] == "AL4_EXPRFI" 
		If AKW->( dbSeek(xFilial("AKW")+cCodCubo+cNivel) )
			If !Empty(AKW->AKW_F3)
			   If ConPad1( , , , AKW->AKW_F3 , , , .F. )
					oGdAL4:aCols[nLinGd, nPosCpo] := &(AKW->AKW_RELAC)
				EndIf	
			EndIf
		EndIf
	EndIf
EndIf

Return 

Static Function PcoGravConfig(oGdAL4, nRecnoAux)

// Grava Processo
PcoGravAL3( .T. )

nRecnoAux := AL3->(Recno())
PcoGrvCfgStru(oGdAL4, nRecnoAux, 3)

Return

Static Function PcoAL4IncluiAcols(aHeadAL4, aColsAL4, oGetdados)
Local nX
Local nLenAL4

nLenAL4  := Len(aHeadAL4) + 1

AAdd(aColsAL4,Array( nLenAL4 ))
aColsAL4[Len(aColsAL4)][nLenAL4] := .F.

For nX := 1 TO Len(aHeadAL4)
	If AllTrim(aHeadAL4[nX,2]) == "AL4_CONFIG"
		aColsAL4[Len(aColsAL4), nX] := 	M->AL3_CONFIG
	ElseIf AllTrim(aHeadAL4[nX,2]) == "AL4_CODIGO"
		aColsAL4[Len(aColsAL4), nX] := 	M->AL3_CODIGO
	ElseIf AllTrim(aHeadAL4[nX,2]) == "AL4_DESCRI"
		aColsAL4[Len(aColsAL4), nX] := 	M->AL3_DESCRI
	Else	
		aColsAL4[Len(aColsAL4), nX] := CriaVar(AllTrim(aHeadAL4[nX,2]))
	EndIf	
Next

If oGetdados != NIL
	oGetdados:aCols := aClone(aColsAL4)
	oGetdados:refresh()
EndIf

Return

Static Function PcoGrvCfgStru(oGdAL4, nRecnoAL3, nOpcx)
Local nI, cCampo, nPosCpo, cChvaCols
Local nX
Local cCubeCode, cConfCode

Local nPosNivel := Ascan(oGdAL4:aHeader, {|x| Upper(AllTrim(x[2])) == "AL4_NIVEL" })
Local aRecAL4

DEFAULT nRecnoAL3 := 0
DEFAULT nOpcx := 3

dbSelectArea("AL4")
dbSetOrder(1)

If nOpcx == 3       //inclusao

	//tem que estar posicionado na tabela AL3

	For nX := 1 TO Len(oGdAL4:aCols)
	
		Reclock("AL4",.T.)
		For nI := 1 To FCount()
		
			cCampo := Upper(AllTrim(FieldName(nI)))
			nPosCpo := 	Ascan(oGdAL4:aHeader, {|x| Upper(AllTrim(x[2])) == cCampo })
	        If nPosCpo > 0
				FieldPut(nI, oGdAL4:aCols[nX, nPosCpo])
			EndIf
			
		Next nI
	
		AL4->AL4_FILIAL := xFilial("AL4")
		AL4->AL4_CODIGO := AL3->AL3_CODIGO
		AL4->AL4_CONFIG := AL3->AL3_CONFIG
		MsUnlock()
		
	Next //nX

ElseIf nOpcx == 4       //alteracao

	//tem que estar posicionado na tabela AL3
	cCubeCode := AL3->AL3_CONFIG
	cConfCode := AL3->AL3_CODIGO
		
	dbSelectArea("AL4")
	dbSetOrder(3)
    
    //Carrega os registro referente acols e se nao encontrar coloca zero (0)
    aRecAL4 := {}
	For nX := 1 TO Len(oGdAL4:aCols)

		cChvaCols := xFilial("AL4")+cCubeCode+cConfCode+oGdAL4:aCols[nX, nPosNivel]
		
		If AL4->( dbSeek(cChvaCols) ) .And. Ascan(aRecAL4, Recno()) == 0
			aAdd(aRecAL4, Recno() )
		Else
			aAdd(aRecAL4, 0	)
		EndIf
		
	Next  //nX
	
	For nX := 1 TO Len(oGdAL4:aCols)
	
		If aRecAL4[nX] == 0
			Reclock("AL4",.T.)  //inclui novo
		Else
			dbGoto(aRecAL4[nX])
			Reclock("AL4",.F.)  //altera existente
		EndIf

		If oGdAL4:aCols[nX, Len(oGdAL4:aHeader)+1] //se foi deletado
			dbDelete()
			MsUnlock()
		Else      
			//altera ou inclui o registro	
			For nI := 1 To FCount()
			
				cCampo := Upper(AllTrim(FieldName(nI)))
				nPosCpo := 	Ascan(oGdAL4:aHeader, {|x| Upper(AllTrim(x[2])) == cCampo })
		        If nPosCpo > 0
					FieldPut(nI, oGdAL4:aCols[nX, nPosCpo])
				EndIf
				
			Next nI
		
			AL4->AL4_FILIAL := xFilial("AL4")
			AL4->AL4_CODIGO := AL3->AL3_CODIGO
			AL4->AL4_CONFIG := AL3->AL3_CONFIG
			MsUnlock()
			
		EndIf	
	
	Next  //nX

EndIf

Return

Static Function PcoAtCfgStructSet(oCjtCfgCube, nElemCjt )
//atualiza o Conjunto de Cubos - Estrutura do arquivo posicionado
Local oLstAL4, cChv, oCuboSel, cCubeCode, cCubeConf
Local oCfgCubo, oCfgStru

If Valtype(oCjtCfgCube) == "O"
	cCubeCode := AL3->AL3_CONFIG
	cCubeConf := AL3->AL3_CODIGO

	//Crio um novo objeto Lista de Registros - Estrutura do Cubo Posicionado
	oLstAL4 := List_Records():New() 
	oLstAL4:SetAlias("AL4")
	oLstAL4:SetIndex(3)
	cChv := xFilial("AL4")+cCubeCode+cCubeConf
	oLstAL4:SetSeek_CodeBlock( {|| cChv } )
	oLstAL4:SetWhile_CodeBlock( {|| AL4_FILIAL+AL4_CONFIG+AL4_CODIGO == cChv } )
	
	//preenche os registros
	oLstAL4:Fill_Records()

	oCjtCfgCube:SetPosition(nElemCjt) 	//posiciona no elemento nX do conjto de cubos
	oCfgCubo := oCjtCfgCube:GetConfig()
    oCfgStru := oCfgCubo:SetCube_StructCfg(oLstAL4)
	
EndIf

Return


Static Function PcoAddCfgTree(oTree, oCjtCfgCube, nRecAL3, bActionConfig)
Local oConfig
Local oLstAL3, nY, cCargoAux
Local lNoFilho := ( PcoRecnoCargo(oTree)==0 )
Local nLevel1 := PcoLevel1Cargo(oTree)

dbSelectArea("AL3")
dbSetOrder(3)

dbGoto(nRecAL3)

cChv := AL3->AL3_FILIAL+AL3->AL3_CONFIG+AL3->AL3_CODIGO

//Crio um novo objeto Lista de Registros - Estrutura do Cubo Posicionado
oLstAL3 := List_Records():New() 
oLstAL3:SetAlias("AL3")
oLstAL3:SetIndex(3)
oLstAL3:SetSeek_CodeBlock( {|| cChv } )
oLstAL3:SetWhile_CodeBlock( {|| AL3_FILIAL+AL3_CONFIG+AL3_CODIGO == cChv } )

//preenche os registros
oLstAL3:Fill_Records()
//posiciona no primeiro e unico registro da lista
oLstAL3:SetPosition(1)
oLstAL3:SetRecord()

//Crio um novo objeto Lista de Registros - Estrutura do Cubo Posicionado
oLstAL4 := List_Records():New() 
oLstAL4:SetAlias("AL4")
oLstAL4:SetIndex(3)

oLstAL4:SetSeek_CodeBlock( {|| cChv } )
oLstAL4:SetWhile_CodeBlock( {|| AL4_FILIAL+AL4_CONFIG+AL4_CODIGO == cChv } )

//preenche os registros
oLstAL4:Fill_Records()

 //cria novo objeto que contera as configuracoes de cubo
oConfig := Configuration_Cube():New()
oConfig:SetCubeCfg_DataGeneral(oLstAL3)
oConfig:SetCube_StructCfg(oLstAL4)

oCjtCfgCube:SetAddCfgCube_Set(oConfig)

nY := oCjtCfgCube:CountConfig()
oCjtCfgCube:SetPosition(nY)

cCargoAux := PcoCodeCargo(nLevel1, nY, "AL3", oLstAL3) 

oTree:AddItem(	Eval(aDescri[2]), ;
				cCargoAux, ;
				"FILTRO", ;
				"FILTRO", ;
				If(lNoFilho, 2, 1),;
				bActionConfig)

oTree:TreeSeek(cCargoAux)

Return


Static Function PcoCopiar( cAlias, oGet, oGetDados )
Local aRetorno := ARRAY(3), aAuxRet := {}
Local nX

aRetorno[1] := cAlias
//tem que estar posicionado no registro correspondente
dbSelectArea(cAlias)

For nX := 1 TO FCOUNT()
	cCampo := Upper(AllTrim(FieldName(nX)))
	cConteudo := FieldGet(nX)
	aAdd(aAuxRet, { cCampo, cConteudo } )
Next // nX
aRetorno[2] := aClone(aAuxRet)

If 		cAlias == "AL1"

		aRetorno[3] := aClone({ oGetDados:aHeader, oGetDados:aCols })

ElseIf 	cAlias == "AL3"

		aRetorno[3] := aClone({ oGetDados:aHeader, oGetDados:aCols })

ElseIf 	cAlias == "AKJ"

		aRetorno[3] := NIL

EndIf

Return( aClone(aRetorno) )


Static Function PcoVerCola(aCopia, cAliasPosic)
Local lRet := .F.
Local nPosCpo

If aCopia[1] != NIL
	If cAliasPosic == "AL1"
	 	If aCopia[1] == cAliasPosic
			lRet := .T.
		EndIf	
	ElseIf cAliasPosic == "AL3"	
		nPosCpo := Ascan(aCopia[2], {|x| x[1] == "AL3_CONFIG" })
		If nPosCpo > 0
			lRet := ( aCopia[2, nPosCpo, 2] == AL1->AL1_CONFIG )
		EndIf
	ElseIf cAliasPosic == "AKJ"	
		nPosCpo := Ascan(aCopia[2], {|x| x[1] == "AKJ_CONFIG" })
		If nPosCpo > 0 
			lRet := ( aCopia[2, nPosCpo, 2] == AL1->AL1_CONFIG )
		EndIf
	EndIf
EndIf

Return(lRet)

Static Function PcoBtColar( cAlias, nRecnoAux, aCopy )
Local oGet, oWizard, NX, nZ
Local oGdAKW, aHeadAKW, aColsAKW, nLenAKW
Local oGdAL4, aHeadAL4, aColsAL4, nLenAL4
Local nPosCod, nPosNiv, nPosDesc, nPosCpo
Local lGravou := .F.

Local aButtons := {}

Local bAtuaEnch := { |cAlias, lGet_Inclui |	lGet_Inclui := If(lGet_Inclui == NIL,  .F., lGet_Inclui), ;
												dbSelectArea(cAlias), ;
												RegToMemory(cAlias,lGet_Inclui) }
Local bPesqPad, bFiltroCfg
Local aCpoAux, cCampo, cConteudo


//colocado estas variaveis para nao dar erro na exibicao da MSMGET
Private aTELA[0][0]
Private aGETS[0]

// manipula as variáveis públicas para permitir a alteração
INCLUI := .T.
ALTERA := .F.
EXCLUI := .F.
//Private nNivelAux := 0
If cAlias == "AL1"

	aAdd(aButtons, { "BMPCPO"	,"BMPCPO"	,''	,{|| a190Suges(oGdAKW) },STR0030} )  //"Campos Pre-selecionados"

	dbSelectArea("AKW")
		
	aHeadAKW := GetaHeader("AKW",,{"AKW_CONFIG"},{})
	nLenAKW  := Len(aHeadAKW) + 1
	//altera o inicializador padrao para a getdados dos campos AKW_COD / AKW_NIVEL	
	nPosCod := Ascan(aHeadAKW, {|x| Upper(AllTrim(x[2])) == "AKW_COD" })
	//nPosNiv := Ascan(aHeadAKW, {|x| Upper(AllTrim(x[2])) == "AKW_NIVEL" })
	If nPosCod > 0
		aHeadAKW[nPosCod, 12] := "M->AL1_CONFIG"
	EndIf
	/*If nPosNiv > 0
		aHeadAKW[nPosNiv, 12] := "StrZero(nNivelAux++, Len(AKW->AKW_NIVEL))"
	EndIf*/
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do aCols do AKW                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aColsAKW := {}
		
	For nX := 1 TO Len(aCopy[3, 2])
	
		AAdd(aColsAKW,Array( nLenAKW ))
		aColsAKW[Len(aColsAKW), nLenAKW] := .F.
		
		For nZ := 1 TO Len(aCopy[3, 1])
			cCampo := Upper(AllTrim(aCopy[3, 1, nZ, 2]))
			nPosCpo := Ascan(aHeadAKW, {|x| Upper(AllTrim(x[2])) == cCampo })
			If nPosCpo > 0
				aColsAKW[ Len(aColsAKW), nPosCpo ] := aCopy[3, 2, nX, nZ]
			EndIf	
		Next  //nZ

	Next //nX
		
	oWizard := APWizard():New(	STR0002/*<chTitle>*/,; //"Atencao" //"Atencao"
								STR0094/*<chMsg>*/, ; //"Este assistente lhe ajudara a incluir um cubo gerencial."
								STR0111/*<cTitle>*/, ;  //"Inclusao de Cubo Gerencial   (Colar)"
								STR0096/*<cText>*/,;  //"Voce devera preencher o formulario na tela seguinte para inclusao do cubo gerencial."
								{|| (oGet:EnchRefreshAll(), .T.)}/*<bNext>*/, ;
								{|| .T.}/*<bFinish>*/,;
								/*<.lPanel.>*/, , , /*<.lNoFirst.>*/)
								
	oWizard:NewPanel( 	STR0112/*<chTitle>*/,;  //"Cubo Gerencial (Colar)"
						STR0113/*<chMsg>*/, ;  //"Neste passo voce deverá preencher os campos do formulario para inclusao do cubo gerencial."
						{||.T.}/*<bBack>*/, ;
						{|| If(Obrigatorio(oGet:aGets,oGet:aTela), ;
									( Eval(bAtuaEnch, "AKW", .T.), ;
										If(oGdAKW == NIL, ;
											(	oGdAKW := PcoGetDadosCreate(oWizard:oMPanel[3], aHeadAKW, aColsAKW,"+AKW_NIVEL"), ;
												oGdAKW:aCols := aClone(aColsAKW) , ;
												oGdAKW:refresh() ;
											) ;
										, NIL), ;
										PcoFillaCols(oGdAKW, M->AL1_CONFIG, nPosCod ),  .T. ) ;
							, .F.) }/*<bNext>*/, ;
						{||.T.}/*<bFinish>*/,;
						.T./*<.lPanel.>*/,;
					 	{||.T.}/*<bExecute>*/ )
						
	oWizard:NewPanel( 	STR0114/*<chTitle>*/,;  //"Cubo Gerencial   (Colar)"
						STR0098/*<chMsg>*/, ;  //"Neste passo voce deverá preencher o formulario para inclusao do cubo gerencial."
						{||.T.}/*<bBack>*/, ;
						{||.T.}/*<bNext>*/, ;
						{||If( PcoVldAKW(oGdAKW), ;
							(  lGravou := .T., PcoGravCubo(oGdAKW, @nRecnoAux) ,.T. ) ;
							, .F.);
						}/*<bFinish>*/,;
						.T./*<.lPanel.>*/,;
					 	{||.T.}/*<bExecute>*/ )
	

	Eval(bAtuaEnch, cAlias, .T. )
	aCpoAux := { "AL1_FILIAL", "AL1_CONFIG", "AL1_CONCDE", "AL1_CHAVER" }
	
	For nX := 1 TO Len(aCopy[2])
		cCampo := Upper(AllTrim(aCopy[2, nX, 1]))
		cConteudo :=  aCopy[2, nX, 2]
        If Ascan(aCpoAux, cCampo) == 0
			M->&(cCampo) := cConteudo
		EndIf
	Next //nX
	
	oGet := PcoCreateGet("AL1",3, 3, oWizard:oMPanel[2])
	aoBt := CriaBotoes(aButtons, oWizard:oMPanel[3])
	
	oWizard:Activate( .T./*<.lCenter.>*/,;
							 {||.T.}/*<bValid>*/, ;
							 {||.T.}/*<bInit>*/, ;
							 {||.T.}/*<bWhen>*/ )

ElseIf cAlias == "AKJ"

	oWizard := APWizard():New(	STR0115/*<chTitle>*/,; //"Atencao" //"Atencao         (Colar)"
								STR0099/*<chMsg>*/, ; //"Este assistente lhe ajudara a incluir um tipo de bloqueio para o cubo gerencial."
								STR0100/*<cTitle>*/, ;  //"Inclusao de Tipo de Bloqueio para Cubo Gerencial"
								STR0101/*<cText>*/,;  //"Voce devera preencher o formulario na tela seguinte para inclusao do tipo de bloqueio para cubo gerencial."
								{|| .T.}/*<bNext>*/, ;
								{|| PCOVldMrg(.T.)}/*<bFinish>*/,;
								/*<.lPanel.>*/, , , /*<.lNoFirst.>*/)

	oWizard:NewPanel( 	STR0116/*<chTitle>*/,;  //"Tipo de Bloqueio           (Colar)"
						STR0103/*<chMsg>*/, ;  //"Neste passo voce deverá preencher o formulario para inclusao do tipo de bloqueio."
						{||.T.}/*<bBack>*/, ;
						{|| ( Eval(bAtuaEnch, "AKJ", .T.),  .T. ) }/*<bNext>*/, ;
						{|| PCOVldMrg(.T.) .AND. Iif(Obrigatorio(oGet:aGets,oGet:aTela), ;
									(  lGravou := .T., PcoGravTpBloq(@nRecnoAux, .T.) , .T. ) ;
								, .F.) }/*<bFinish>*/,;
						.T./*<.lPanel.>*/,;
					 	{||.T.}/*<bExecute>*/ )

	Eval(bAtuaEnch, cAlias, .T. )
	M->AKJ_CONFIG := AL1->AL1_CONFIG
	
	aCpoAux := { "AKJ_FILIAL", "AKJ_COD", "AKJ_CONFIG" }
	
	For nX := 1 TO Len(aCopy[2])
		cCampo := Upper(AllTrim(aCopy[2, nX, 1]))
		cConteudo :=  aCopy[2, nX, 2]
        If Ascan(aCpoAux, cCampo) == 0
			M->&(cCampo) := cConteudo
		EndIf
	Next //nX
	
	oGet := PcoCreateGet("AKJ",3, 3, oWizard:oMPanel[2],,"PCOVldMrg()")
	
	oWizard:Activate( .T./*<.lCenter.>*/,;
							 {||.T.}/*<bValid>*/, ;
							 {||.T.}/*<bInit>*/, ;
							 {||.T.}/*<bWhen>*/ ) 							 							 										 
							 

ElseIf cAlias == "AL3"

	bPesqPad 	:= {|| 	M->AL4_CONFIG := M->AL3_CONFIG, ;
						PcoCfgPesq(M->AL3_CONFIG, oGdAL4)}

	bFiltroCfg := {|| PcoCfgFil(M->AL3_CONFIG, M->AL3_CODIGO, oGdAL4, .F.) }

	aAdd(aButtons, { BMPPESQUISA, BMPPESQUISA	, ''	, bPesqPad		, STR0039 } )  //"Consulta Padrao"
	aAdd(aButtons, { BMPFILTRO 	, BMPFILTRO		, ''	, bFiltroCfg	, STR0041 } )  //"Configurar Filtro"

	dbSelectArea("AL4")

	aHeadAL4 := GetaHeader("AL4",,{"AL4_CONFIG", "AL4_CODIGO"},{})
	nLenAL4  := Len(aHeadAL4) + 1
	//altera o inicializador padrao para a getdados dos campos AL4_COD / AL4_NIVEL	
	nPosDesc := Ascan(aHeadAL4, {|x| Upper(AllTrim(x[2])) == "AL4_DESCRI" })

	If nPosDesc > 0
		aHeadAL4[nPosDesc, 12] := "M->AL3_DESCRI"
	EndIf
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do aCols do AL4                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	aColsAL4 := {}
		
	For nX := 1 TO Len(aCopy[3, 2])
	
		AAdd(aColsAL4,Array( nLenAL4 ))
		aColsAL4[Len(aColsAL4), nLenAL4] := .F.
		
		For nZ := 1 TO Len(aCopy[3, 1])
			cCampo := Upper(AllTrim(aCopy[3, 1, nZ, 2]))
			nPosCpo := Ascan(aHeadAL4, {|x| Upper(AllTrim(x[2])) == cCampo })
			If nPosCpo > 0
				aColsAL4[ Len(aColsAL4), nPosCpo ] := aCopy[3, 2, nX, nZ]
			EndIf	
		Next //nZ

	Next // nX
		
	oWizard := APWizard():New(	STR0117/*<chTitle>*/,; //"Atencao" //"Atencao              (Colar)"
								STR0104/*<chMsg>*/, ; //"Este assistente lhe ajudara a incluir uma configuracao para o cubo gerencial."
								STR0105/*<cTitle>*/, ;  //"Inclusao de Configuracao do Cubo Gerencial"
								STR0106/*<cText>*/,;  //"Voce devera preencher o formulario na tela seguinte para inclusao da configuracao do cubo gerencial."
								{|| .T.}/*<bNext>*/, ;
								{|| .T.}/*<bFinish>*/,;
								/*<.lPanel.>*/, , , /*<.lNoFirst.>*/)


	oWizard:NewPanel( 	STR0118/*<chTitle>*/,;  //"Configuracao do Cubo Gerencial       (Colar)"
						STR0108/*<chMsg>*/, ;  //"Neste passo voce deverá preencher o formulario para inclusao da configuracao do cubo gerencial."
						{||.T.}/*<bBack>*/, ;
						{|| If(Obrigatorio(oGet:aGets,oGet:aTela), ;
								( 	Eval(bAtuaEnch, "AL4", .T.), ;
									M->AL4_CONFIG := M->AL3_CONFIG, ;
									M->AL4_CODIGO := M->AL3_CODIGO, ;
										If(oGdAL4 == NIL, ;
											(	oGdAL4 := PcoGetDadosCreate(oWizard:oMPanel[3], aHeadAL4, aColsAL4), ;
												oGdAL4:aCols := aClone(aColsAL4), ;
												oGdAL4:refresh() ;
											) ;
										,NIL),PcoFillaCols(oGdAL4, M->AL3_DESCRI, nPosDesc ),  .T. ) ;											
							, .F.) }/*<bNext>*/, ;
						{||.T.}/*<bFinish>*/,;
						.T./*<.lPanel.>*/,;
					 	{||.T.}/*<bExecute>*/ )

	oWizard:NewPanel( 	STR0119/*<chTitle>*/,;  //"Configuracao de Cubo Gerencial               (Colar)"
						STR0098/*<chMsg>*/, ;  //"Neste passo voce deverá preencher o formulario para inclusao do cubo gerencial."
						{||.T.}/*<bBack>*/, ;
						{||.T.}/*<bNext>*/, ;
						{|| If(PcoVldAL4(oGdAL4), ;
								(  lGravou := .T., PcoGravConfig(oGdAL4, @nRecnoAux) ,.T. ) ;
								, .F.) ;
						}/*<bFinish>*/,;
						.T./*<.lPanel.>*/,;
					 	{||.T.}/*<bExecute>*/ )
	

	Eval(bAtuaEnch, cAlias, .T. )
	M->AL3_CONFIG := AL1->AL1_CONFIG
	
	aCpoAux := { "AL3_FILIAL", "AL3_CONFIG", "AL3_CODIGO" }
	
	For nX := 1 TO Len(aCopy[2])
		cCampo := Upper(AllTrim(aCopy[2, nX, 1]))
		cConteudo :=  aCopy[2, nX, 2]
        If Ascan(aCpoAux, cCampo) == 0
			M->&(cCampo) := cConteudo
		EndIf
	Next //nX
	
	oGet := PcoCreateGet("AL3",3, 3, oWizard:oMPanel[2])
	aoBt := CriaBotoes(aButtons, oWizard:oMPanel[3])
	
	oWizard:Activate( .T./*<.lCenter.>*/,;
							 {||.T.}/*<bValid>*/, ;
							 {||.T.}/*<bInit>*/, ;
							 {||.T.}/*<bWhen>*/ )

EndIf

Return(lGravou)

Static Function PcoFillaCols(oGetDados, xValue, nPosCol )
Local nX

If nPosCol > 0

	For nX := 1 TO Len(oGetDados:aCols)
		oGetDados:aCols[nX, nPosCol] := xValue
	Next

EndIf

Return	

Function PcoInaCols(aCols,nCol,nAtu,New)
Local nX
Local lRet	:= .T.

Default New := &(ReadVar())

For nX := 1 to Len(aCols)

	If nAtu<>nX .and. aCols[nX,nCol]==New
		HELP( " ",1,"JAGRAVADO" )
		lRet := .F.	
	EndIf

Next

Return lRet


Function PCOVLBLQ()

dbSelectArea("AKW")
dbSetOrder(1)
AKW->( dbSeek(xFilial("AKW")+M->AKJ_CONFIG + M->AKJ_NIVPR) )
IF AKW->AKW_ALIAS == "AL2" 
	Alert (STR0136)	//"Não é possivel utilizar o nivel Tipo de Saldo como comparativo."
	lRet := .F.
Else
	lRet := .T.
EndIf  

Return lRet


//Função para habilitar edição e desabilitar o objt oTree
Static Function HabEdit(oTree)

oTree:SetDisable()
lEdicao := .T.

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PCOVldMrg
Função para validação dos campos de percentual de margem para aviso de pré-bloqueio e/ou envio de e-mail
Utilizando o grupo de usuários do ambiente Planejamento e Controle Orçamentário.

@return lOk Retorno que indica se o e-mail foi enviado ou não.
@author marylly.araujo
@since 16/07/2013
@version MP11
/*/
//-------------------------------------------------------------------

Function PCOVldMrg(lTudoOk) 
Local lRet		:= .T.
Default lTudoOk := .F.

If Select("AKJ") > 0 .AND. (INCLUI .OR. ALTERA)
	If AKJ->(FieldPos("AKJ_PRCMRG")) > 0 .AND. AKJ->(FieldPos("AKJ_GRPUSR")) > 0 .AND. AKJ->(FieldPos("AKJ_TIPMSG")) > 0
		If lRet .AND. ValType(M->AKJ_PRCMRG) == 'C' // Quando o valor de percentual é inserido com o sinal de negativo na frente, o valor do campo entra como caracter na validação.
			If SUBSTR(M->AKJ_PRCMRG,0,1) == "-"
				Help("  ",1,"PRCMGRNEG",,STR0142 ,1,0) //"O valor do percentual de margem para aviso do pré-bloqueio orçamentário não pode ser negativo.   "
				lRet := .F.
			EndIf
		ElseIf lRet .AND. ValType(M->AKJ_PRCMRG) == 'N'
			If !Positivo(M->AKJ_PRCMRG)
				Help("  ",1,"PRCMGRNEG",,STR0142 ,1,0) //"O valor do percentual de margem para aviso do pré-bloqueio orçamentário não pode ser negativo.   "
				lRet := .F.
			EndIf
		EndIf	
		If lTudoOk
			If EMPTY(M->AKJ_TIPMSG) .AND. EMPTY(M->AKJ_GRPUSR) .AND. M->AKJ_PRCMRG == 0.00
				lRet = .T.
			Else				 								
				If lRet .And. M->AKJ_PRCMRG > 0.00 .AND. EMPTY(M->AKJ_GRPUSR)
					Help("  ",1,"PRCMRGVLD",,STR0138 ,1,0) //"Se for utilizada a margem para aviso de pré-bloqueio orçamentário, é necessário que seja informado o grupo de usuários do ambiente Planejamento e Controle Orçamento que receberão os avisos emitidos pelo sistema."
					lRet := .F.
				EndIf
							
				If lRet .AND. M->AKJ_PRCMRG >= 100.00
					Help("  ",1,"PRCMRGVLD",,STR0139 ,1,0) //"Se for utilizada a margem para aviso de pré-bloqueio orçamentário, é necessário que seja informado o grupo de usuários do ambiente Planejamento e Controle Orçamento que receberão os avisos emitidos pelo sistema."
					lRet := .F.
				EndIf
			
				If lRet .AND. !EMPTY(M->AKJ_GRPUSR)
					lRet := ExistCpo("ALB",M->AKJ_GRPUSR)
				EndIf
				
				If lRet .AND. M->AKJ_PRCMRG == 0.00 .AND. !EMPTY(M->AKJ_GRPUSR)
					Help("  ",1,"GRPMRGVLD",,STR0140 ,1,0) //"Se for utilizada a margem para aviso de pré-bloqueio orçamentário, é necessário que seja informado o grupo de usuários do ambiente Planejamento e Controle Orçamento que receberão os avisos emitidos pelo sistema."
					lRet := .F.
				EndIf
			
				If lRet .AND. EMPTY(M->AKJ_TIPMSG)
					Help("  ",1,"GRPTPMSGVLD",,STR0141 ,1,0) //""Se for utilizada a margem para aviso de pré-bloqueio orçamentário, é necessário que tipo de aviso será utilizado neste processo.""
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PCOEntiSXB
Funcao para retornar a consulta padr? das Entidades de Cubo.

@return cEntidade Retorno da Entidade de Cubo.
@author Alessandro Santos
@since 04/06/2019
/*/
//-------------------------------------------------------------------

Function PCOEntiSXB()

Local cEntidade := ""

If Valtype(M->AKJ_PRVCFG) == "U" .Or. Valtype(M->AKJ_REACFG) == "U"
	RegToMemory("AKJ")
EndIf

cEntidade := xFilial("AL3")+Posicione("AL3",1,xFilial("AL3")+iif(ReadVar()=="M->AKJ_NIVPR",M->AKJ_PRVCFG,M->AKJ_REACFG),"AL3_CONFIG")

Return cEntidade