#INCLUDE "PROTHEUS.CH"
#INCLUDE "TAFR122.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "APWIZARD.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFR122
@type			function
@description	Fun��o principal do relat�rio de Confer�ncia de Incid�ncias de Verbas.
@author			Felipe C. Seolin
@since			05/04/2019
/*/
//---------------------------------------------------------------------
Function TAFR122()

	Local aFilV3I  	:= {}
	Local cMessage  := ""
	Local cPeriod   := ""
	Local cQryDel   := "" 
	Local nHeight   := 0
	Local nX        := 0
	Local lCancel   := .T.
	Local aFils     := {}
	Local aSize     := FWGetDialogSize()
	Local cModeC8R  := Upper(AllTrim(FWModeAccess("C8R",1)+FWModeAccess("C8R",2)+FWModeAccess("C8R",3)))
	Local cModeSRV  := Upper(AllTrim(FWModeAccess("SRV",1)+FWModeAccess("SRV",2)+FWModeAccess("SRV",3)))
	Local cModeV3I  := Upper(AllTrim(FWModeAccess("V3I",1)+FWModeAccess("V3I",2)+FWModeAccess("V3I",3)))

	Private cTela	 := TAFGeraID("TAF")	
	Private cPrdBsc  :=	""
	Private cFilRubs :=	""
	Private cFilV3I  := ""
	Private lIncons  := .F.
	Private oBrwsRub := FwmBrowse():New()
	
	If cModeV3I <> cModeC8R .Or. cModeV3I <> cModeSRV
		MsgAlert(	"O modo de compartilhamento da tabela V3I est� divergente da tabela de rubricas do TAF (C8R) e/ou da tabela de verbas do GPE (SRV). " + CRLF + CRLF +;
					"Solicite ao respons�vel pela administra��o do sistema para corre��o dessa diverg�ncia.","Aten��o!" )

		// � realizada dele��o dos registros na tabela V3I para permitir ao usu�rio a altera��o do modo de compartilhamento via SIGACFG. 
		cQryDel += "DELETE FROM " + RetSqlName("V3I") 
		TcSQLExec( cQryDel )

	ElseIf GrantAccess( @cMessage )
		If TafColumnPos( "V3I_TELA" )
			If GetParWiz(@cPeriod,@lIncons)
				
				cPrdBsc := SubStr(cPeriod,3,4)+SubStr(cPeriod,1,2)

				aFils := xFunTelaFil( .T.,,,,, .F., lCancel, .T. ) 
				
				If Len(aFils) > 0

					For nX := 1 to Len(aFils)

						If aFils[nX][1]

							AAdd(aFilV3I, xFilial("C8R", aFils[nX][2]))

							cFilRubs += Iif(Empty(cFilRubs), "", ",") + "'" + aFils[nX][2] + "'"

						EndIf

					Next nX

					cFilV3I	:= TAFCacheFil("V3I", aFilV3I, .T.)
					aVerbRH := fBuscaVrb(cPrdBsc, cFilRubs) //Fun��o RH

					If Len(aVerbRH) > 0					
						FWMsgRun(, {|| ConfIncdRb(aVerbRH,cTela) }, STR0015, STR0016)	//"Processando" # "Realizando a confer�ncia das incid�ncias das r�bricas"			

						/*----------------------------
						Constru��o do Painel Principal
						----------------------------*/
						nHeight := aSize[4]
						cPeriod := STR0007 + ": " + Substr(cPeriod, 1, 2) + "/" + Substr(cPeriod, 3, 4)

						oBrwsRub:SetAlias('V3I')
						oBrwsRub:SetDescription(STR0001 + Space((nHeight/8)-90) + cPeriod ) //"Per�odo de Apura��o"
						oBrwsRub:DisableReport()

						oBrwsRub:AddLegend( "V3I_INCONS == '1'", "RED", STR0014 ) //"Registro Inconsistente"
						oBrwsRub:AddLegend( "V3I_INCONS == '2'", "GREEN", STR0013 ) //"Registro Consistente"

						oBrwsRub:AddFilter( STR0014, "V3I_INCONS == '1'", .F., .F. ) //"Registro Inconsistente"
						oBrwsRub:AddFilter( STR0013, "V3I_INCONS == '2'", .F., .F. ) //"Registro Consistente"

						oBrwsRub:SetFilterDefault( "V3I_TELA == '" + cTela + "' " )

						/*-------------------
						Ativa��o da Interface
						-------------------*/

						oBrwsRub:Activate()
					Else
						MsgAlert(STR0024) //"Registros n�o encontrados para o per�odo e filial(is) informada(s)"
					EndIf

					cQryDel += "DELETE FROM " + RetSqlName("V3I") + " WHERE V3I_FILIAL IN"
					cQryDel += " ( SELECT FILIAIS.FILIAL FROM " + cFilV3I + " FILIAIS ) " 
					cQryDel += "AND V3I_PERIOD = '" + cPrdBsc + "' AND V3I_TELA = '" + cTela + "' "

					TcSQLExec( cQryDel )

				EndIf
			Else
				MsgAlert("Opera��o cancelada pelo usu�rio.")
			EndIf
		Else
			MsgAlert("Opera��o cancelada pois o Dicion�rio de Dados est� desatualizado." + CRLF + CRLF ;
						+ "Para utiliza��o do relat�rio ser� necess�rio atualizar o dicion�rio";
						+ " com a �ltima vers�o que encontra-se no portal.")
		EndIf
	Else
		Aviso( STR0001, cMessage, { STR0002 }, 2 ) //##"Confer�ncia de Incid�ncias de Verbas" ##"Encerrar"
	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
@type			function
@description	Funcao gen�rica MVC com as op��es de Menu
@author			Eduardo Sukeda
@since			09/04/2019
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0017 ACTION 'VIEWDEF.TAFR122' OPERATION 2 ACCESS 0   //'Visualizar'
	ADD OPTION aRotina TITLE STR0019 ACTION 'GerarRCIV()' OPERATION 6 ACCESS 0      //'Gerar Relat�rio'
	ADD OPTION aRotina TITLE STR0018 ACTION 'FReavInc(cPrdBsc,cTela)' OPERATION 6 ACCESS 0 //'ReAvaliar RH x TAF'

Return( aRotina )

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@type			function
@description	Fun��o gen�rica do modelo MVC.
@author			Bruno Rosa
@since			15/04/2019
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	Local oStrRub := FWFormStruct(1,"V3I",{|cCampo| AllTrim(cCampo) $ "V3I_FILIAL|V3I_ID"})
	Local oStrPRH := FWFormStruct(1,"V3I",{|cCampo| AllTrim(cCampo) $ "V3I_RUBRH|V3I_DESCRH|V3I_RHNTRB|V3I_FLINSS|V3I_FLIRRF|V3I_FLFGTS"})
	Local oStrTAF := FWFormStruct(1,"V3I",{|cCampo| AllTrim(cCampo) $ "V3I_RUBTAF|V3I_DSCTAF|V3I_TFNTRB|V3I_TFINSS|V3I_TFIRRF|V3I_TFFGTS"})

	Local oStrOutRh := FWFormStruct(1,"V3I",{|cCampo| AllTrim(cCampo) $ "V3I_RHTIPO|V3I_REF|V3I_RHINSS|V3I_RHIRRF|V3I_RHFGTS|V3I_IDCALC"})
	Local oStrOutTf := FWFormStruct(1,"V3I",{|cCampo| AllTrim(cCampo) $ "V3I_TPRUB|V3I_DTINI|V3I_DTFIM|V3I_IDTBRU"})

	Local oModel  := MPFormModel():New('TAFR122')

	oModel:SetDescription(STR0001) //"Confer�ncia de Incid�ncias de VerbaS"

	oStrPRH:AddField(STR0028							    			,;	// 	[01]  C   Titulo do campo //"Descri��o Natureza"
					 STR0028							    			,;	// 	[02]  C   ToolTip do campo //"Descri��o Natureza"
					 "DESNATRH"										    ,;	// 	[03]  C   Id do Field
					 "C"												,;	// 	[04]  C   Tipo do campo
					 250						    					,;	// 	[05]  N   Tamanho do campo
					 0						                            ,;	// 	[06]  N   Decimal do campo
					 NIL												,;	// 	[07]  B   Code-block de valida��o do campo
					 {|| .T.}											,;	// 	[08]  B   Code-block de valida��o When do campo
					 NIL												,;	//	[09]  A   Lista de valores permitido do campo
					 .F.												,;	//	[10]  L   Indica se o campo tem preenchimento obrigat�rio
					 {|| POSICIONE("C89",2,FwxFilial("C89")+V3I->V3I_RHNTRB,"C89_DESCRI")},;  //	[11]  B   Code-block de inicializacao do campo
					 NIL												,;	//	[12]  L   Indica se trata-se de um campo chave
					 .T.												,;	//	[13]  L   Indica se o campo pode receber valor em uma opera��o de update.
					 .T.												)	// 	[14]  L   Indica se o campo � virtual

	oStrPRH:AddField(STR0029								    		,;	// 	[01]  C   Titulo do campo //"Descri��o INSS"
					 STR0029								    		,;	// 	[02]  C   ToolTip do campo //"Descri��o INSS"
					 "DESINSSRH"									    ,;	// 	[03]  C   Id do Field
					 "C"												,;	// 	[04]  C   Tipo do campo
					 250											    ,;	// 	[05]  N   Tamanho do campo
					 0						                            ,;	// 	[06]  N   Decimal do campo
					 NIL												,;	// 	[07]  B   Code-block de valida��o do campo
					 {|| .T.}											,;	// 	[08]  B   Code-block de valida��o When do campo
					 NIL												,;	//	[09]  A   Lista de valores permitido do campo
					 .F.												,;	//	[10]  L   Indica se o campo tem preenchimento obrigat�rio
					 {|| POSICIONE("C8T",2,FwxFilial("C8T")+V3I->V3I_FLINSS,"C8T_DESCRI")},;  //	[11]  B   Code-block de inicializacao do campo
					 NIL												,;	//	[12]  L   Indica se trata-se de um campo chave
					 .T.												,;	//	[13]  L   Indica se o campo pode receber valor em uma opera��o de update.
					 .T.												)	// 	[14]  L   Indica se o campo � virtual

	oStrPRH:AddField(STR0030	  										,;	// 	[01]  C   Titulo do campo //"Descri��o IRRF"
					 STR0030								    		,;	// 	[02]  C   ToolTip do campo //"Descri��o IRRF"
					 "DESIRRFRH"									    ,;	// 	[03]  C   Id do Field
					 "C"												,;	// 	[04]  C   Tipo do campo
					 250											    ,;	// 	[05]  N   Tamanho do campo
					 0						                            ,;	// 	[06]  N   Decimal do campo
					 NIL												,;	// 	[07]  B   Code-block de valida��o do campo
					 {|| .T.}											,;	// 	[08]  B   Code-block de valida��o When do campo
					 NIL												,;	//	[09]  A   Lista de valores permitido do campo
					 .F.												,;	//	[10]  L   Indica se o campo tem preenchimento obrigat�rio
					 {|| POSICIONE("C8U",2,FwxFilial("C8U")+V3I->V3I_FLIRRF,"C8U_DESCRI")},;  //	[11]  B   Code-block de inicializacao do campo
					 NIL												,;	//	[12]  L   Indica se trata-se de um campo chave
					 .T.												,;	//	[13]  L   Indica se o campo pode receber valor em uma opera��o de update.
					 .T.												)	// 	[14]  L   Indica se o campo � virtual


	oStrTAF:AddField(STR0028							   				,;	// 	[01]  C   Titulo do campo //"Descri��o Natureza"
					 STR0028							    			,;	// 	[02]  C   ToolTip do campo //"Descri��o Natureza"
					 "DESNATTAF"									    ,;	// 	[03]  C   Id do Field
					 "C"												,;	// 	[04]  C   Tipo do campo
					 250						    					,;	// 	[05]  N   Tamanho do campo
					 0						                            ,;	// 	[06]  N   Decimal do campo
					 NIL												,;	// 	[07]  B   Code-block de valida��o do campo
					 {|| .T.}											,;	// 	[08]  B   Code-block de valida��o When do campo
					 NIL												,;	//	[09]  A   Lista de valores permitido do campo
					 .F.												,;	//	[10]  L   Indica se o campo tem preenchimento obrigat�rio
					 {|| POSICIONE("C89",2,FwxFilial("C89")+V3I->V3I_TFNTRB,"C89_DESCRI")},;  //	[11]  B   Code-block de inicializacao do campo
					 NIL												,;	//	[12]  L   Indica se trata-se de um campo chave
					 .T.												,;	//	[13]  L   Indica se o campo pode receber valor em uma opera��o de update.
					 .T.												)	// 	[14]  L   Indica se o campo � virtual

	oStrTAF:AddField(STR0029								    		,;	// 	[01]  C   Titulo do campo //"Descri��o INSS"
					 STR0029								    		,;	// 	[02]  C   ToolTip do campo //"Descri��o INSS"
					 "DESINSSTAF"									    ,;	// 	[03]  C   Id do Field
					 "C"												,;	// 	[04]  C   Tipo do campo
					 250											    ,;	// 	[05]  N   Tamanho do campo
					 0						                            ,;	// 	[06]  N   Decimal do campo
					 NIL												,;	// 	[07]  B   Code-block de valida��o do campo
					 {|| .T.}											,;	// 	[08]  B   Code-block de valida��o When do campo
					 NIL												,;	//	[09]  A   Lista de valores permitido do campo
					 .F.												,;	//	[10]  L   Indica se o campo tem preenchimento obrigat�rio
					 {|| POSICIONE("C8T",2,FwxFilial("C8T")+V3I->V3I_TFINSS,"C8T_DESCRI")},;  //	[11]  B   Code-block de inicializacao do campo
					 NIL												,;	//	[12]  L   Indica se trata-se de um campo chave
					 .T.												,;	//	[13]  L   Indica se o campo pode receber valor em uma opera��o de update.
					 .T.												)	// 	[14]  L   Indica se o campo � virtual

	oStrTAF:AddField(STR0030	  										,;	// 	[01]  C   Titulo do campo //"Descri��o IRRF"
					 STR0030								    		,;	// 	[02]  C   ToolTip do campo //"Descri��o IRRF"
					 "DESIRRFTAF"									    ,;	// 	[03]  C   Id do Field
					 "C"												,;	// 	[04]  C   Tipo do campo
					 250											    ,;	// 	[05]  N   Tamanho do campo
					 0						                            ,;	// 	[06]  N   Decimal do campo
					 NIL												,;	// 	[07]  B   Code-block de valida��o do campo
					 {|| .T.}											,;	// 	[08]  B   Code-block de valida��o When do campo
					 NIL												,;	//	[09]  A   Lista de valores permitido do campo
					 .F.												,;	//	[10]  L   Indica se o campo tem preenchimento obrigat�rio
					 {|| POSICIONE("C8U",2,FwxFilial("C8U")+V3I->V3I_TFIRRF,"C8U_DESCRI")},;  //	[11]  B   Code-block de inicializacao do campo
					 NIL												,;	//	[12]  L   Indica se trata-se de um campo chave
					 .T.												,;	//	[13]  L   Indica se o campo pode receber valor em uma opera��o de update.
					 .T.												)	// 	[14]  L   Indica se o campo � virtual


	oModel:AddFields("V3IRUBIC", , oStrRub)
	oModel:AddFields("V3IRUBRH", "V3IRUBIC",oStrPRH)
	oModel:AddFields("V3IRUBTAF", "V3IRUBIC", oStrTAF)

	oModel:AddFields("V3IRHACI", "V3IRUBRH",oStrPRH)
	oModel:AddFields("V3IRHBAI", "V3IRUBRH",oStrOutRh)

	oModel:AddFields("V3ITFACI", "V3IRUBTAF",oStrTAF)
	oModel:AddFields("V3ITFBAI", "V3IRUBTAF",oStrOutTf)

	oModel:SetPrimaryKey({"V3I_FILIAL","V3I_ID"})

Return oModel       

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@type			function
@description	Funcao gen�rica MVC da View
@author			Bruno Rosa
@since			15/04/2019
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	Local oModel	:= FWLoadModel( 'TAFR122' )
	Local oStrRub	:= FWFormStruct(2,"V3I",{|cCampo| AllTrim(cCampo) $ "V3I_FILIAL|V3I_ID"})
	Local oStrPRH	:= FWFormStruct(2,"V3I",{|cCampo| AllTrim(cCampo) $ "V3I_RUBRH|V3I_DESCRH|V3I_RHNTRB|V3I_FLINSS|V3I_FLIRRF|V3I_FLFGTS"})
	Local oStrTAF	:= FWFormStruct(2,"V3I",{|cCampo| AllTrim(cCampo) $ "V3I_RUBTAF|V3I_DSCTAF|V3I_TFNTRB|V3I_TFINSS|V3I_TFIRRF|V3I_TFFGTS"})

	Local oStrOutRh := FWFormStruct(2,"V3I",{|cCampo| AllTrim(cCampo) $ "V3I_RHTIPO|V3I_REF|V3I_RHINSS|V3I_RHIRRF|V3I_RHFGTS|V3I_IDCALC"})
	Local oStrOutTf := FWFormStruct(2,"V3I",{|cCampo| AllTrim(cCampo) $ "V3I_TPRUB|V3I_DTINI|V3I_DTFIM|V3I_IDTBRU"})

	Local oView		:= FWFormView():New()

	oStrPRH:RemoveField("V3I_ID")
	oStrTAF:RemoveField("V3I_ID")

	oStrOutRh:RemoveField("V3I_ID")
	oStrOutTf:RemoveField("V3I_ID")

	oStrPRH:AddField("DESNATRH"							            	,;	// [01]  C   Nome do Campo
					 "06"								         		,;	// [02]  C   Ordem
					 STR0028						        			,;	// [03]  C   Titulo do campo //"Descri��o Natureza"
					 STR0028      										,;	// [04]  C   Descricao do campo //"Descri��o Natureza"
					 NIL					    						,;	// [05]  A   Array com Help
					 "C"						    					,;	// [06]  C   Tipo do campo
					 ""								         			,;	// [07]  C   Picture
					 NIL									     		,;	// [08]  B   Bloco de Picture Var
					 NIL										    	,;	// [09]  C   Consulta F3
					 .F.											    ,;	// [10]  L   Indica se o campo � alteravel
					 NIL		    									,;	// [11]  C   Pasta do campo
					 ""			 	     								,;	// [12]  C   Agrupamento do campo
					 NIL				     							,;	// [13]  A   Lista de valores permitido do campo (Combo)
					 NIL					    						,;	// [14]  N   Tamanho maximo da maior op��o do combo
					 NIL						    					,;	// [15]  C   Inicializador de Browse
					 .T.							    				,;	// [16]  L   Indica se o campo � virtual
					 NIL								    			,;	// [17]  C   Picture Variavel
					 NIL									    		)	// [18]  L   Indica pulo de linha ap�s o campo

	oStrPRH:AddField("DESINSSRH"							            ,;	// [01]  C   Nome do Campo
					 "08"								         		,;	// [02]  C   Ordem
					 STR0029							        		,;	// [03]  C   Titulo do campo //"Descri��o INSS"
					 STR0029	      									,;	// [04]  C   Descricao do campo //"Descri��o INSS"
					 NIL					    						,;	// [05]  A   Array com Help
					 "C"						    					,;	// [06]  C   Tipo do campo
					 ""								         			,;	// [07]  C   Picture
					 NIL									     		,;	// [08]  B   Bloco de Picture Var
					 NIL										    	,;	// [09]  C   Consulta F3
					 .F.											    ,;	// [10]  L   Indica se o campo � alteravel
					 NIL		    									,;	// [11]  C   Pasta do campo
					 ""			 	     								,;	// [12]  C   Agrupamento do campo
					 NIL				     							,;	// [13]  A   Lista de valores permitido do campo (Combo)
					 NIL					    						,;	// [14]  N   Tamanho maximo da maior op��o do combo
					 NIL						    					,;	// [15]  C   Inicializador de Browse
					 .T.							    				,;	// [16]  L   Indica se o campo � virtual
					 NIL								    			,;	// [17]  C   Picture Variavel
					 NIL									    		)	// [18]  L   Indica pulo de linha ap�s o campo

	oStrPRH:AddField("DESIRRFRH"							            ,;	// [01]  C   Nome do Campo
					 "10"								         		,;	// [02]  C   Ordem 
					 STR0030							        		,;	// [03]  C   Titulo do campo //"Descri��o IRRF"
					 STR0030  	    									,;	// [04]  C   Descricao do campo //"Descri��o IRRF"
					 NIL					    						,;	// [05]  A   Array com Help
					 "C"						    					,;	// [06]  C   Tipo do campo
					 ""								         			,;	// [07]  C   Picture
					 NIL									     		,;	// [08]  B   Bloco de Picture Var
					 NIL										    	,;	// [09]  C   Consulta F3
					 .F.											    ,;	// [10]  L   Indica se o campo � alteravel
					 NIL		    									,;	// [11]  C   Pasta do campo
					 ""			 	     								,;	// [12]  C   Agrupamento do campo
					 NIL				     							,;	// [13]  A   Lista de valores permitido do campo (Combo)
					 NIL					    						,;	// [14]  N   Tamanho maximo da maior op��o do combo
					 NIL						    					,;	// [15]  C   Inicializador de Browse
					 .T.							    				,;	// [16]  L   Indica se o campo � virtual
					 NIL								    			,;	// [17]  C   Picture Variavel
					 NIL									    		)	// [18]  L   Indica pulo de linha ap�s o campo

	oStrTAF:AddField("DESNATTAF"							            ,;	// [01]  C   Nome do Campo
					 "20"								         		,;	// [02]  C   Ordem
					 STR0028						        			,;	// [03]  C   Titulo do campo //"Descri��o Natureza"
					 STR0028     										,;	// [04]  C   Descricao do campo //"Descri��o Natureza"
					 NIL					    						,;	// [05]  A   Array com Help
					 "C"						    					,;	// [06]  C   Tipo do campo
					 ""								         			,;	// [07]  C   Picture
					 NIL									     		,;	// [08]  B   Bloco de Picture Var
					 NIL										    	,;	// [09]  C   Consulta F3
					 .F.											    ,;	// [10]  L   Indica se o campo � alteravel
					 NIL		    									,;	// [11]  C   Pasta do campo
					 ""			 	     								,;	// [12]  C   Agrupamento do campo
					 NIL				     							,;	// [13]  A   Lista de valores permitido do campo (Combo)
					 NIL					    						,;	// [14]  N   Tamanho maximo da maior op��o do combo
					 NIL						    					,;	// [15]  C   Inicializador de Browse
					 .T.							    				,;	// [16]  L   Indica se o campo � virtual
					 NIL								    			,;	// [17]  C   Picture Variavel
					 NIL									    		)	// [18]  L   Indica pulo de linha ap�s o campo

	oStrTAF:AddField("DESINSSTAF"							            ,;	// [01]  C   Nome do Campo
					 "22"								         		,;	// [02]  C   Ordem
					 STR0029							      			,;	// [03]  C   Titulo do campo //"Descri��o INSS"
					 STR0029	      									,;	// [04]  C   Descricao do campo //"Descri��o INSS"
					 NIL					    						,;	// [05]  A   Array com Help
					 "C"						    					,;	// [06]  C   Tipo do campo
					 ""								         			,;	// [07]  C   Picture
					 NIL									     		,;	// [08]  B   Bloco de Picture Var
					 NIL										    	,;	// [09]  C   Consulta F3
					 .F.											    ,;	// [10]  L   Indica se o campo � alteravel
					 NIL		    									,;	// [11]  C   Pasta do campo
					 ""			 	     								,;	// [12]  C   Agrupamento do campo
					 NIL				     							,;	// [13]  A   Lista de valores permitido do campo (Combo)
					 NIL					    						,;	// [14]  N   Tamanho maximo da maior op��o do combo
					 NIL						    					,;	// [15]  C   Inicializador de Browse
					 .T.							    				,;	// [16]  L   Indica se o campo � virtual
					 NIL								    			,;	// [17]  C   Picture Variavel
					 NIL									    		)	// [18]  L   Indica pulo de linha ap�s o campo

	oStrTAF:AddField("DESIRRFTAF"							            ,;	// [01]  C   Nome do Campo
					 "24"								         		,;	// [02]  C   Ordem
					 STR0030							        		,;	// [03]  C   Titulo do campo //"Descri��o IRRF"
					 STR0030  	    									,;	// [04]  C   Descricao do campo //"Descri��o IRRF"
					 NIL					    						,;	// [05]  A   Array com Help
					 "C"						    					,;	// [06]  C   Tipo do campo
					 ""								         			,;	// [07]  C   Picture
					 NIL									     		,;	// [08]  B   Bloco de Picture Var
					 NIL										    	,;	// [09]  C   Consulta F3
					 .F.											    ,;	// [10]  L   Indica se o campo � alteravel
					 NIL		    									,;	// [11]  C   Pasta do campo
					 ""			 	     								,;	// [12]  C   Agrupamento do campo
					 NIL				     							,;	// [13]  A   Lista de valores permitido do campo (Combo)
					 NIL					    						,;	// [14]  N   Tamanho maximo da maior op��o do combo
					 NIL						    					,;	// [15]  C   Inicializador de Browse
					 .T.							    				,;	// [16]  L   Indica se o campo � virtual
					 NIL								    			,;	// [17]  C   Picture Variavel
					 NIL									    		)	// [18]  L   Indica pulo de linha ap�s o campo


	oView:SetModel( oModel )

	oView:AddField("VIEW_RUB",oStrRub,"V3IRUBIC")
	oView:AddField("VIEW_RH",oStrPRH,"V3IRHACI")
	oView:AddField("VIEW_TAF",oStrTAF,"V3IRUBTAF")

	oView:AddField("VIEW_RH1",oStrOutRh,"V3IRHBAI")
	oView:AddField("VIEW_TF1",oStrOutTf,"V3ITFBAI")

	oView:CreateHorizontalBox("CABEC",05)
	oView:CreateHorizontalBox("COMPER",95)

	oView:CreateVerticalBox( 'RHOESQ', 50, 'COMPER' )
	oView:CreateVerticalBox( 'TAFDIR', 50, 'COMPER' )

	oView:CreateHorizontalBox("RHCIMA",65,'RHOESQ')
	oView:CreateHorizontalBox("RHBAIXO",35,'RHOESQ')

	oView:CreateHorizontalBox("TFCIMA",65,'TAFDIR')
	oView:CreateHorizontalBox("TFBAIXO",35,'TAFDIR')

	oView:SetOwnerView("VIEW_RUB",'CABEC')
	oView:SetOwnerView("VIEW_RH",'RHCIMA')
	oView:SetOwnerView("VIEW_TAF",'TFCIMA')

	oView:SetOwnerView("VIEW_RH1",'RHBAIXO')
	oView:SetOwnerView("VIEW_TF1",'TFBAIXO')

	// Liga a identificacao do componente
	oView:EnableTitleView( 'VIEW_RUB', STR0020 )  //"Informa��es RH X TAF"
	oView:EnableTitleView( 'VIEW_RH' , STR0021 )  //"Recursos Humanos"
	oView:EnableTitleView( 'VIEW_TAF', STR0022 )  //"TAF E-Social"

	oView:EnableTitleView( 'VIEW_RH1', STR0025 ) //"Demais Informa��es - RH" 
	oView:EnableTitleView( 'VIEW_TF1', STR0026 ) //"Demais Informa��es - TAF" 

	oStrPRH:SetProperty("V3I_DESCRH",MVC_VIEW_INSERTLINE,.T.)
	oStrPRH:SetProperty("DESNATRH"  ,MVC_VIEW_INSERTLINE,.T.)
	oStrPRH:SetProperty("DESINSSRH" ,MVC_VIEW_INSERTLINE,.T.)
	oStrPRH:SetProperty("DESIRRFRH" ,MVC_VIEW_INSERTLINE,.T.)
	oStrPRH:SetProperty("V3I_FLFGTS",MVC_VIEW_INSERTLINE,.T.)

	//Alterada a ordem
	oStrPRH:SetProperty("V3I_RHNTRB",MVC_VIEW_ORDEM,"05")	
	oStrPRH:SetProperty("V3I_FLINSS",MVC_VIEW_ORDEM,"07")
	oStrPRH:SetProperty("V3I_FLIRRF",MVC_VIEW_ORDEM,"09")
	oStrPRH:SetProperty("V3I_FLFGTS",MVC_VIEW_ORDEM,"11")

	oStrTAF:SetProperty("V3I_DSCTAF",MVC_VIEW_INSERTLINE,.T.)
	oStrTAF:SetProperty("DESNATTAF" ,MVC_VIEW_INSERTLINE,.T.)
	oStrTAF:SetProperty("DESINSSTAF",MVC_VIEW_INSERTLINE,.T.)
	oStrTAF:SetProperty("DESIRRFTAF",MVC_VIEW_INSERTLINE,.T.)
	oStrTAF:SetProperty("V3I_TFFGTS",MVC_VIEW_INSERTLINE,.T.)

	oStrTAF:SetProperty("V3I_TFNTRB",MVC_VIEW_ORDEM , "19")
	oStrTAF:SetProperty("V3I_TFINSS",MVC_VIEW_ORDEM , "21")
	oStrTAF:SetProperty("V3I_TFIRRF",MVC_VIEW_ORDEM , "23")
	oStrTAF:SetProperty("V3I_TFFGTS",MVC_VIEW_ORDEM , "25")



Return oView

//---------------------------------------------------------------------
/*/{Protheus.doc} GrantAccess
@type			function
@description	Fun��o para verificar a permiss�o de acesso ao relat�rio.
@author			Felipe C. Seolin
@since			05/04/2019
@param			cMessage	-	Mensagem de erro
@return			lRet 		-	Indica se possui permiss�o
/*/
//---------------------------------------------------------------------
Static Function GrantAccess( cMessage )

	Local lProtheus	:=	GetNewPar( "MV_RHTAF", .F. )
	Local lRet		:=	.F.

	If lProtheus
		DBSelectArea( "C1E" )
		C1E->( DBSetOrder( 3 ) )
		If C1E->( MsSeek( xFilial( "C1E" ) + cFilAnt + "1" ) )
			If C1E->C1E_MATRIZ
				lRet := .T.
			EndIf
		EndIf

		If !lRet
			cMessage := STR0003 //"Apenas Filial Matriz possui permiss�o de de acesso a rotina de confer�ncia de incid�ncias de verbas."
		EndIf
	Else
		lRet := .F.

		cMessage := STR0031 //A rotina para confer�ncia de incid�ncias de verbas no TAF est� em processo de constru��o para sua linha de RH para mais informa��es entre em contato com o suporte da TOTVS.
	EndIf

Return( lRet )



//---------------------------------------------------------------------
/*/{Protheus.doc} GetParWiz()
@type			function
@description	Fun��o para selecionar os par�metos.
@author			Veronica de Almeida
@since			09/05/2019
/*/
//---------------------------------------------------------------------
Static Function GetParWiz(cPeriodo,lIncons)
Local lRet		:= .F.
Local oWizard	:= Nil
Local nLinha	:= 10
Local nColuna1	:= 20
Local nColuna2	:= 130
Local nAltLinha	:= 10
Local nIncons	:= 1
Local oPnl1		:= Nil
Local oPnl2		:= Nil
Local bValidPer	:= {|cPeriod|ValidPeriod( cPeriodo )}
Local oFont1	:= TFont():New("Arial",,-14,,.F.,,,,.T.,.F.)
Local cPanel1	:= ""

cPeriodo	:= Space( 6 )
lIncons		:= .T.

cPanel1		:= STR0032 + CRLF + CRLF //"Este relat�rio tem como finalidade auxiliar a confer�ncia das rubricas (verbas) entre o Recusos Humanos e o TAF." 
cPanel1		+= STR0033	//"Ser�o exibidas todas as rubricas que possuirem movimenta��o no per�odo informado."


Define WIZARD oWizard;
		TITLE STR0034; //"Relat�rio de Confer�ncia de Incid�ncia de Verbas RH X TAF"
		HEADER STR0035; //"TOTVS Automa��o Fiscal"
		MESSAGE "T A F";
		TEXT "";
		NEXT { || .T. };
		FINISH { || .T. };
		NOTESC

		oPnl1		:=�	TPanel():New( 10, 10, , oWizard:oMPanel[ 1 ],, .F., .F.,,, 270, 105, .T., .F. )

		TSay():New( nLinha, nColuna1, { || cPanel1  }, oPnl1,,oFont1,,,, .T., ,, 250, 105,,,,,,.T. )

	CREATE PANEL oWizard;
			HEADER STR0035;	//"TOTVS Automa��o Fiscal"
			MESSAGE STR0036; //Preencha corretamente as informa��es solicitadas.
			BACK { || .T. };
			NEXT { || .T. };
			FINISH {||lRet := .T.}

			oPnl2	:=�	TPanel():New( 10, 10, , oWizard:oMPanel[ 2 ],, .F., .F.,,, 270, 105, .T., .F. )

			TSay():New( nLinha, nColuna1, { || STR0037 }, oPnl2,,oFont1,,,, .T., /*CLR_BLUE*/,, 90, 20,,,,,,.T. )	// "Per�odo de Apura��o"
			TSay():New( nLinha, nColuna2, { || STR0038 }, oPnl2,,oFont1,,,, .T., /*CLR_BLUE*/,, 250, 70,,,,,,.T. ) //"Apenas Inconsist�ncias?"

			nLinha	+=	nAltLinha*1.5
			TGet():New( nLinha, nColuna1, {|u| if( PCount() > 0, cPeriodo := u, cPeriodo )}, oPnl2, 20, nAltLinha, "@R 99/9999",bValidPer, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, cPeriodo,,,, )		
			oRadio 	:= tRadMenu():New(nLinha,nColuna2,{"1-Sim","2-N�o"},{|u|IIf(PCount() == 0,nIncons,nIncons := u)},oPnl2,,,,,,,,250,nAltLinha,,,,.T.)
		
Activate WIZARD oWizard Centered

lIncons := IIF(nIncons == 1,.T.,.F.)

Return lRet


//---------------------------------------------------------------------
/*/{Protheus.doc} ValidPeriod
@type			function
@description	Valida��o da entrada de dados para o per�odo desejado.
@author			Felipe C. Seolin
@since			08/04/2019
@param			cPeriod	-	Per�odo informado
@return			lRet	-	Indica se todas as condi��es foram respeitadas
/*/
//---------------------------------------------------------------------
Static Function ValidPeriod( cPeriod )

	Local nMonth	:=	0
	Local nYear		:=	0
	Local lRet		:=	.T.

	If Empty( cPeriod )
		MsgInfo( STR0008 ) //"Informe um per�odo."
		lRet := .F.
	Else
		If Len( AllTrim( cPeriod ) ) < 6
			MsgInfo( STR0009 ) //"Per�odo informado possui valor inv�lido."
			lRet := .F.
		Else
			nMonth := Val( SubStr( cPeriod, 1, 2 ) )
			nYear := Val( SubStr( cPeriod, 3, 4 ) )
			If nMonth < 1 .or. nMonth > 12
				MsgInfo( STR0010 ) //"M�s informado possui valor inv�lido."
				lRet := .F.
			ElseIf nYear == 2018 .and. nMonth < 3
				MsgInfo( STR0011 ) //"Per�odo informado possui valor inv�lido para rotinas relacionadas ao eSocial."
				lRet := .F.
			ElseIf nYear < 2018
				MsgInfo( STR0012 ) //"Ano informado possui valor inv�lido para rotinas relacionadas ao eSocial."
				lRet := .F.
			EndIf
		EndIf
	EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} ConfIncdRub
@type			function
@description	Confer�ncia das Verbas com as Rubricas.
@author			Bruno de Oliveira
@since			12/04/2019
@param			aVerbRH	-	Array, verbas do RH
/*/
//---------------------------------------------------------------------
Static Function ConfIncdRb(aVerbRH,cTela)

	Local nX		:= 0

	Local cNatRub   := ""
	Local cInssRub	:= ""
	Local cIrrfRub	:= ""
	Local cQryDel	:= ""
	Local cFilRef   := ""

	Local lNatRub	:= .T.
	Local lInssRub	:= .T.
	Local lIrrfRub	:= .T.
	Local lFgtsRub	:= .T.
	Local lResult	:= .T.	
	Local lContinua := .T.

	Local cTamCdRb  := space(TAMSX3("C8R_CODRUB")[1] - TAMSX3("RV_COD")[1])

	cQryDel += "DELETE FROM " + RetSqlName("V3I") + " WHERE V3I_FILIAL IN
	cQryDel += " ( SELECT FILIAIS.FILIAL FROM " + cFilV3I + " FILIAIS ) " 
	cQryDel += "AND V3I_PERIOD = '" + cPrdBsc + "' AND V3I_TELA = '" + cTela + "' "

	TcSQLExec( cQryDel )

	DbSelectArea("C8R")

	For nX := 1 To Len(aVerbRH)


		cFilRef := aVerbRH[nX][1]

		C8R->(DbSetOrder(3))

		If C8R->(DbSeek(cFilRef + aVerbRH[nX][2] + cTamCdRb + "1"))
			While !C8R->(EOF()) .AND. (C8R->C8R_FILIAL+C8R->C8R_CODRUB+C8R->C8R_ATIVO == cFilRef + aVerbRH[nX][2] + cTamCdRb + "1")

				//C89 - Natureza
				cNatRub := Posicione("C89",1,xFilial("C89")+C8R->C8R_NATRUB,"C89_CODIGO")
				lNatRub := Alltrim(aVerbRH[nX][6]) == Alltrim(cNatRub)

				//C8T - INSS
				cInssRub := Posicione("C8T",1,xFilial("C8T")+C8R->C8R_CINTPS,"C8T_CODIGO")
				lInssRub := Alltrim(aVerbRH[nX][9]) == Alltrim(cInssRub)

				//C8U - IRRF
				cIrrfRub := Posicione("C8U",1,xFilial("C8U")+C8R->C8R_CINTIR,"C8U_CODIGO")
				lIrrfRub := Alltrim(aVerbRH[nX][13]) == Alltrim(cIrrfRub)

				//FGTS
				lFgtsRub := Alltrim(aVerbRH[nX][11]) == Alltrim(C8R->C8R_CINTFG)

				lResult := lNatRub .AND. lInssRub .AND. lIrrfRub .AND. lFgtsRub
				
				If lIncons //Apenas Inconsistentes
					If lResult
						lContinua := .F.
					Else
						lContinua := .T.
					EndIf
				EndIf
				
				If lContinua
					RecLock( "V3I" , .T. )	
					V3I->V3I_INCONS := IIF(!lResult,"1" /*Inconsist�ncia*/,"2" /*Consist�ncia*/)
					V3I->V3I_ID     := GetSX8Num("V3I","V3I_ID",,1)
					V3I->V3I_PERIOD := cPrdBsc				
					//Verbas - RH
					V3I->V3I_FILIAL := aVerbRH[nX][1]
					V3I->V3I_RUBRH  := aVerbRH[nX][2]
					V3I->V3I_DESCRH := Alltrim(aVerbRH[nX][3])
					V3I->V3I_RHTIPO := aVerbRH[nX][4]
					V3I->V3I_REF    := aVerbRH[nX][5]				
					V3I->V3I_RHNTRB := aVerbRH[nX][6]
					V3I->V3I_IDCALC := aVerbRH[nX][7]			
					V3I->V3I_RHINSS := IIF(aVerbRH[nX][8] == "S","1","2")
					V3I->V3I_FLINSS := aVerbRH[nX][9]
					V3I->V3I_RHFGTS := IIF(aVerbRH[nX][10] == "S","1","2")
					V3I->V3I_FLFGTS := aVerbRH[nX][11]
					V3I->V3I_RHIRRF := IIF(aVerbRH[nX][12] == "S","1","2")
					V3I->V3I_FLIRRF := aVerbRH[nX][13]
					//Rubricas - TAF
					V3I->V3I_RUBTAF := C8R->C8R_CODRUB
					V3I->V3I_DSCTAF := Alltrim(C8R->C8R_DESRUB)
					V3I->V3I_TPRUB  := C8R->C8R_INDTRB
					V3I->V3I_TFINSS := cInssRub
					V3I->V3I_TFIRRF := cIrrfRub
					V3I->V3I_TFFGTS := C8R->C8R_CINTFG
					V3I->V3I_TFNTRB := cNatRub
					V3I->V3I_DTINI  := C8R->C8R_DTINI 
					V3I->V3I_DTFIM  := C8R->C8R_DTFIN 
					V3I->V3I_IDTBRU := C8R->C8R_IDTBRU
					V3I->V3I_TELA	:= cTela
					V3I->(MsUnlock())
	
					V3I->(ConfirmSx8())
				EndIf

				C8R->(DbSkip())
				lContinua := .T.
			End		
		Else
			RecLock( "V3I" , .T. )	
				V3I->V3I_INCONS := "1" /*Inconsist�ncia*/
				V3I->V3I_ID     := GetSX8Num("V3I","V3I_ID",,1)
				V3I->V3I_PERIOD := cPrdBsc				
				//Verbas - RH
				V3I->V3I_FILIAL := aVerbRH[nX][1]
				V3I->V3I_RUBRH  := aVerbRH[nX][2]
				V3I->V3I_DESCRH := Alltrim(aVerbRH[nX][3])
				V3I->V3I_RHTIPO := aVerbRH[nX][4]
				V3I->V3I_REF    := aVerbRH[nX][5]				
				V3I->V3I_RHNTRB := aVerbRH[nX][6]
				V3I->V3I_IDCALC := aVerbRH[nX][7]			
				V3I->V3I_RHINSS := IIF(aVerbRH[nX][8] == "S","1","2")
				V3I->V3I_FLINSS := aVerbRH[nX][9]
				V3I->V3I_RHFGTS := IIF(aVerbRH[nX][10] == "S","1","2")
				V3I->V3I_FLFGTS := aVerbRH[nX][11]
				V3I->V3I_RHIRRF := IIF(aVerbRH[nX][12] == "S","1","2")
				V3I->V3I_FLIRRF := aVerbRH[nX][13]
				V3I->V3I_TELA	:= cTela
			V3I->(MsUnlock())
	
			V3I->(ConfirmSx8())
		EndIf

	Next nX

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} FReavInc
@type			function
@description	Reavalia Confer�ncia das Verbas com as Rubricas.
@author			Bruno Rosa
@since			15/04/2019
@param			cPeriod	-	Per�odo da Apura��o
/*/
//---------------------------------------------------------------------
Function FReavInc(cPeriod,cTela)

	Local aVerbRH := {}

	aVerbRH := fBuscaVrb(cPrdBsc,cFilRubs) //Fun��o RH

	FWMsgRun(, {|| ConfIncdRb(aVerbRH,cTela) }, STR0015, STR0023) //"Processando" # "Reavaliando as incid�ncias das r�bricas"	

	oBrwsRub:Refresh(.T.)

Return nil

//---------------------------------------------------------------------
/*/{Protheus.doc} GerarRCIV
@type			function
@description	Relat�rio de Incidencias.
@author			Eduardo Sukeda
@since			29/04/2019
/*/
//---------------------------------------------------------------------
Function GerarRCIV()

Local oExcel	:= FWMSExcel():New()
Local cAliasQry	:= GetNextAlias()
Local cTabela	:= "CONFER�NCIA DE INCID�NCIAS DE VERBAS - PER�ODO: "  + Substr(cPrdBsc, 5, 6) + "/" + Substr(cPrdBsc, 1, 4)
Local cArquivo	:= "rel_conferencia_incidencia_verbas_" + Substr(cPrdBsc, 5, 6) + "_" + Substr(cPrdBsc, 1, 4) + "_" + DToS( MsDate() ) + "_" + StrTran( Time(), ":", "" ) + ".XLS"
Local cDefPath	:= GetSrvProfString( "StartPath", "\system\" )
Local cPath		:= ""
Local cSelect	:= ""
Local cFrom		:= ""
Local cWhere	:= ""
Local cValFil	:= ""
Local aResult	:= {}
Local aDados	:= {}
Local aCol		:= {}
Local aFiltro	:= oBrwsRub:FWFilter():GetFilter() 
Local nX		:= 0
Local nI		:= 0
Local nZ        := 0
Local nFiltro	:= 0
Local nOpc		:= 0

Local cFiltro	:= ""
If GetRemoteType() <>  5 // WebAPP
	cPath := cGetFile( "Diret�rio" + "|*.*", "Procurar", 0,, .T., GETF_LOCALHARD + GETF_RETDIRECTORY, .T. )
EndIf

If !Empty(cPath) .Or. GetRemoteType() ==  5

	cSelect := "V3I_FILIAL,"
	cSelect += "V3I_RUBRH, "
	cSelect += "V3I_DESCRH,"
	cSelect += "V3I_RUBTAF,"	
	cSelect += "V3I_DSCTAF,"
	cSelect += "V3I_FLINSS,"
	cSelect += "V3I_TFINSS,"
	cSelect += "V3I_FLIRRF,"
	cSelect += "V3I_TFIRRF,"
	cSelect += "V3I_FLFGTS,"
	cSelect += "V3I_TFFGTS,"
	cSelect += "V3I_RHNTRB,"
	cSelect += "V3I_TFNTRB,"
	cSelect += "V3I_RHTIPO,"
	cSelect += "V3I_REF,   "
	cSelect += "V3I_RHINSS,"
	cSelect += "V3I_RHIRRF,"
	cSelect += "V3I_RHFGTS,"
	cSelect += "V3I_IDCALC,"
	cSelect += "V3I_TPRUB, "
	cSelect += "V3I_DTINI, "
	cSelect += "V3I_DTFIM, "
	cSelect += "V3I_IDTBRU "
	cFrom 	:= RetSqlName( "V3I" ) 
	cWhere	:= "V3I_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilV3I + " FILIAIS ) "
	cWhere 	+= "AND  V3I_PERIOD = '" + cPrdBsc + "'  "
	cWhere 	+= "AND D_E_L_E_T_ = ' '  "
	cWhere  += "AND V3I_TELA = '" + cTela + "' "

	If Len(aFiltro) > 0
		For nFiltro := 1 To Len(aFiltro)
			cFiltro += ' AND ' + IIf( Empty( aFiltro[nFiltro][3] ), aFiltro[nFiltro][2], aFiltro[nFiltro][3] )
		Next

		cFiltro	:= StrTran(cFiltro,'==','=')

		cWhere += cFiltro
	EndIf

	cWhere 	+= "ORDER BY V3I_FILIAL "

	cSelect := "%" + cSelect + "%"
	cFrom   := "%" + cFrom + "%"
	cWhere  := "%" + cWhere + "%"

	BeginSql Alias cAliasQry
		SELECT
			%Exp:cSelect%
		FROM
			%Exp:cFrom%
		WHERE
			%Exp:cWhere%
	EndSql

	While (cAliasQry)->(!Eof())

		aAdd( aResult,	{(cAliasQry)->V3I_FILIAL;
						,(cAliasQry)->V3I_RUBRH ;
						,(cAliasQry)->V3I_DESCRH;
						,(cAliasQry)->V3I_RUBTAF;						
						,(cAliasQry)->V3I_DSCTAF;
						,(cAliasQry)->V3I_FLINSS;
						,(cAliasQry)->V3I_TFINSS;
						,(cAliasQry)->V3I_FLIRRF;
						,(cAliasQry)->V3I_TFIRRF;
						,(cAliasQry)->V3I_FLFGTS;
						,(cAliasQry)->V3I_TFFGTS;
						,(cAliasQry)->V3I_RHNTRB;
						,(cAliasQry)->V3I_TFNTRB;
						,(cAliasQry)->V3I_RHTIPO;
						,(cAliasQry)->V3I_REF   ;
						,(cAliasQry)->V3I_RHINSS;
						,(cAliasQry)->V3I_RHIRRF;
						,(cAliasQry)->V3I_RHFGTS;
						,(cAliasQry)->V3I_IDCALC;
						,(cAliasQry)->V3I_TPRUB ;
						,(cAliasQry)->V3I_DTINI ; 
						,(cAliasQry)->V3I_DTFIM ;
						,(cAliasQry)->V3I_IDTBRU })

		( cAliasQry )->( DbSkip() ) 

	EndDo

	( cAliasQry )->( DbCloseArea() )

	For nI := 1 To Len(aResult)
		If cValFil == aResult[nI][1]
			aAdd(aDados[Len(aDados)][2], aResult[nI])		
		Else
			cValFil := aResult[nI][1]
			aAdd(aDados,{cValFil,{}})
			aAdd(aDados[Len(aDados)][2], aResult[nI])
		EndIf
	Next nI

	For nZ := 1 To Len(aDados)

		oExcel:AddWorkSheet( aDados[nZ][1] )
		oExcel:AddTable( aDados[nZ][1], cTabela )

		oExcel:AddColumn( aDados[nZ][1], cTabela, "Filial"        		, 1, 1, .F. )
		oExcel:AddColumn( aDados[nZ][1], cTabela, "Cod. Rub. Folha"  	, 1, 1, .F. )
		oExcel:AddColumn( aDados[nZ][1], cTabela, "Desc. Rub. Folha" 	, 1, 1, .F. )
		oExcel:AddColumn( aDados[nZ][1], cTabela, "Cod. Rub TAF"  		, 1, 1, .F. )		
		oExcel:AddColumn( aDados[nZ][1], cTabela, "Desc. Rub. TAF"		, 1, 1, .F. )
		oExcel:AddColumn( aDados[nZ][1], cTabela, "INSS Folha"     		, 1, 1, .F. )
		oExcel:AddColumn( aDados[nZ][1], cTabela, "INSS TAF"      		, 1, 1, .F. )
		oExcel:AddColumn( aDados[nZ][1], cTabela, "IRRF Folha"     		, 1, 1, .F. )
		oExcel:AddColumn( aDados[nZ][1], cTabela, "IRRF TAF"  	  		, 1, 1, .F. )
		oExcel:AddColumn( aDados[nZ][1], cTabela, "FGTS Folha"	     	, 1, 1, .F. )
		oExcel:AddColumn( aDados[nZ][1], cTabela, "FGTS TAF"  			, 1, 1, .F. )
		oExcel:AddColumn( aDados[nZ][1], cTabela, "Nat. Rubrica Folha"  , 1, 1, .F. )
		oExcel:AddColumn( aDados[nZ][1], cTabela, "Nat. Rubrica TAF"  	, 1, 1, .F. )
		oExcel:AddColumn( aDados[nZ][1], cTabela, "Tipo"          		, 1, 1, .F. )
		oExcel:AddColumn( aDados[nZ][1], cTabela, "Refer�ncia"    		, 1, 1, .F. )
		oExcel:AddColumn( aDados[nZ][1], cTabela, "Calc. INSS"    		, 1, 1, .F. )
		oExcel:AddColumn( aDados[nZ][1], cTabela, "Calc. IRRF"    		, 1, 1, .F. )
		oExcel:AddColumn( aDados[nZ][1], cTabela, "Calc. FGTS"    		, 1, 1, .F. )
		oExcel:AddColumn( aDados[nZ][1], cTabela, "ID Calc."      		, 1, 1, .F. )		
		oExcel:AddColumn( aDados[nZ][1], cTabela, "Ind. Tp. Rub"  		, 1, 1, .F. )		
		oExcel:AddColumn( aDados[nZ][1], cTabela, "Per. Ini."     		, 1, 1, .F. )
		oExcel:AddColumn( aDados[nZ][1], cTabela, "Per. Fim"     		, 1, 1, .F. )
		oExcel:AddColumn( aDados[nZ][1], cTabela, "Iden.Tab.Rub." 		, 1, 1, .F. )

		aCol := aDados[nZ][2]

		For nX := 1 to Len( aCol )

			oExcel:AddRow(aDados[nZ][1],cTabela,{aCol[nX][1];
										,aCol[nX][2];
										,aCol[nX][3];
										,aCol[nX][4];
										,aCol[nX][5];
										,GetStrxCod(aCol, nX, 6);
										,GetStrxCod(aCol, nX, 7);
										,GetStrxCod(aCol, nX, 8);
										,GetStrxCod(aCol, nX, 9);
										,GetStrxCod(aCol, nX, 10);
										,GetStrxCod(aCol, nX, 11);
										,aCol[nX][12];
										,aCol[nX][13];
										,GetStrxCod(aCol, nX, 14);
										,GetStrxCod(aCol, nX, 15);
										,GetStrxCod(aCol, nX, 16);
										,GetStrxCod(aCol, nX, 17);
										,GetStrxCod(aCol, nX, 18);
										,aCol[nX][19];
										,GetStrxCod(aCol, nX, 20);
										,aCol[nX][21];
										,aCol[nX][22];
										,aCol[nX][23]})

		Next nX
	Next nZ

	If !Empty( oExcel:aWorkSheet )
		oExcel:Activate()
		oExcel:GetXMLFile( cArquivo )		

		//Para ambiente Smart, n�o conseguimos abrir oOleClient e por isto avisamos sobre o envio por email.
		If GetRemoteType() ==  5 // WebAPP
			nOpc := Aviso("TAF",STR0039+CRLF+CRLF;	//'Selecione a op��o para envio do relat�rio:' 
						 + STR0040 + CRLF ; // "Download: realiza o download no arquivo do relat�rio;"
						 + STR0041,{STR0042,STR0043}) // "E-mail: relat�rio ser� enviado para o e-mail cadastrado para o usu�rio.", 'Download','E-mail'

			If nOpc == 1
				nRet := CpyS2TW( cDefPath + cArquivo , .T. )

				IIF((nRet == 0),MsgAlert(STR0044, "Aten��o"),TAFConOut(STR0045 + str(nRet))) // #"Download conclu�do com sucesso." # "Falha na copia"
			Else
				cPara	 :=	AllTrim(FWSFUser( __cUserId, "DATAUSER", "USR_EMAIL" ))
				cAssunto := STR0046 + Dtoc(MsDate()) + " - " + Time()	// "Relatorio de Conferencia de Incidencias de Verbas.. Extraido em: "
				cAnexo	 := cDefPath + cArquivo
				cMsg	 := STR0046 + Dtoc(MsDate()) + " - " + Time()	//	"Relatorio de Conferencia de Incidencias de Verbas.. Extraido em: "

				If ExistBlock("TAFR122MAIL")
					cMsg :=  ExecBlock("TAFR122MAIL",.F.,.F.,{cMsg})
				Endif

				If !(TAFSETMAIL(,cPara,,,cAssunto,cAnexo,cMsg))
					MsgAlert(STR0047 + cAnexo + ".") // "Erro ao enviar email! Arquivo salvo na pasta "
				Else
					MsgAlert(STR0048 + cPara + STR0049) //"Enviado o relatorio para o email: " , ". Verifique a sua caixa de e-mail!"
				EndIf
			EndIf
		ElseIf ApOleClient( "MSExcel" )
			__CopyFile( cDefPath + cArquivo, cPath + cArquivo )
			oExcelApp := MsExcel():New()
			FWMsgRun(, {|| 	oExcelApp:WorkBooks:Open( cPath + cArquivo ) }, STR0050, STR0051) // "Relat�rio de  Confer�ncia de Incid�ncias de Verbas.","Gerando Relat�rio..."
			oExcelApp:SetVisible( .T. )
		EndIf
	EndIf
EndIf

Return Nil
//---------------------------------------------------------------------
/*/{Protheus.doc} GetStrxCod
@type			function
@description	Transformar c�digos em String concatenadas
@author			Eduardo Sukeda
@since			29/04/2019
/*/
//---------------------------------------------------------------------
Static Function GetStrxCod(aResult, nX, nPos)

Local cRet := ""

If  nPos == 6 .Or. nPos == 7 //INSS
	cRet := EditText(AllTrim(POSICIONE("C8T",2,FwxFilial("C8T")+aResult[nX][nPos],"C8T_CODIGO") + " - " + POSICIONE("C8T",2,FwxFilial("C8T")+aResult[nX][nPos],"C8T_DESCRI")))

ElseIf  nPos == 8 .Or. nPos == 9 //IRRF
	cRet := EditText(AllTrim(POSICIONE("C8U",2,FwxFilial("C8U")+aResult[nX][nPos],"C8U_CODIGO") + " - " + POSICIONE("C8U",2,FwxFilial("C8U")+aResult[nX][nPos],"C8U_DESCRI")))

ElseIf  nPos == 10 .Or. nPos == 11 //FGTS
	If aResult[nX][nPos] == "00" //00=N�o � Base de C�lculo;11=Base C�lculo;12=Base C�lculo 13�;21=Base Calculo Rescis�rio;91=Suspensa em decorr�ncia dec. judicial
		cRet := "00-Nao e Base de Calculo"
	ElseIf aResult[nX][nPos] == "11"
		cRet := "11-Base Calculo"
	ElseIf aResult[nX][nPos] == "12"
		cRet := "12-Base Calculo 13�"
	ElseIf aResult[nX][nPos] == "21"
		cRet := "21-Base Calculo Rescissorio"
	ElseIf aResult[nX][nPos] == "91"
		cRet := "91-Suspensa Em Decorrencia Dec. Judicial"
EndIf

ElseIf nPos == 14
	If aResult[nX][nPos] == "1" //1=Provento;2=Desconto;3=Base (Provento);4=Base (Desconto)
		cRet := "Provento"
	ElseIf aResult[nX][nPos] == "2"
		cRet := "Desconto"
	ElseIf aResult[nX][nPos] == "3"
		cRet := "Base (Provento)"
	ElseIf aResult[nX][nPos] == "4"
		cRet := "Base (Desconto)"
	EndIf

ElseIf nPos == 15
	If aResult[nX][nPos] == "1" //1=Mensal;2=D�cimo Terceiro;3=F�rias
		cRet := "Mensal"
	ElseIf aResult[nX][nPos] == "2"
		cRet := "Decimo Terceiro"
	ElseIf aResult[nX][nPos] == "3"
		cRet := "Ferias"
	EndIf

ElseIf nPos == 16 .Or. nPos == 17 .Or. nPos == 18
	If aResult[nX][nPos] == "1" //1=Mensal;2=D�cimo Terceiro;3=F�rias
		cRet := "Sim"
	ElseIf aResult[nX][nPos] == "2"
		cRet := "Nao"
	EndIf

ElseIf nPos == 20
	If aResult[nX][nPos] == "1" //1=Vencimento;2=Desconto;3=Informativa;4=Informativa dedutora
		cRet := "Vencimento"
	ElseIf aResult[nX][nPos] == "2"
		cRet := "Desconto"
	ElseIf aResult[nX][nPos] == "3"
		cRet := "Informativa"
	ElseIf aResult[nX][nPos] == "4"
		cRet := "Informativa Dedutora"
	EndIf
EndIf

Return cRet

//---------------------------------------------------------------------
/*/{Protheus.doc} EditText
@type			function
@description	Editar o Text
@author			Eduardo Sukeda
@since			29/04/2019
/*/
//---------------------------------------------------------------------
Static Function EditText(cText)

Local cRet 	:= ""
Local nTam 	:= 0
Local nX	:= 0
Local aText := {}

aText := StrTokArr(cText, " ")

For nX := 1 To Len(aText)
	nTam := Len(aText[nX])
	If nTam > 2
		cRet += Upper(SubStr(aText[nX],1,1)) + Lower(SubStr(aText[nX],2,nTam)) + " "
	Else
		cRet += Lower(aText[nX]) + " "
	EndIf
Next nX

Return cRet
