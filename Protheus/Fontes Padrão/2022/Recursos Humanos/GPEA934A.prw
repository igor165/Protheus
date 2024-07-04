#include "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'GPEA934A.CH'

Static lMiddleware  := SuperGetMv("MV_MID",, .F.)
Static lIntTAF		:= ((SuperGetMv("MV_RHTAF",, .F.) == .T.) .AND. Val(SuperGetMv("MV_FASESOC",/*lHelp*/,' ')) >= 1 )
Static cEFDAviso	:= If(cPaisLoc == 'BRA' .And. Findfunction("fEFDAviso"), fEFDAviso(), SuperGetMv("MV_EFDAVIS",, "0")) //Integracao com TAF)
//-------------------------------------------------------------------
/*/{Protheus.doc} function GPEA934A
Rotina para cadastramento de Obras Próprias eSocial na tabela RJ4
@author  Gisele Nuncherino	
@since   20/036/2019
@version V 1.0
/*/
//-------------------------------------------------------------------
FUNCTION GPEA934A()

Local cFiltraRh 	:= ""
Local oBrwRJ4  
Local oDlg
Local nOpca 		:= 1
Local cMsgDesatu	:= ""
Local aDados		:= {}

If !ChkFile("RJ4")
	cMsgDesatu := CRLF + OemToAnsi(STR0009) + CRLF
EndIf																														

If !Findfunction("fVldIniRJ")
	cMsgDesatu += CRLF + OemToAnsi(STR0008)
EndIf

If ( lMiddleware .and. !ChkFile("RJ9") .And. !ChkFile("RJE") )
	cMsgDesatu += CRLF + OemToAnsi(STR0024) + CRLF
EndIf														

If !Empty(cMsgDesatu)
	//ATENCAO"###"Tabela RJ4 não encontrada na base de dados. Execute o UPDDISTR."
	//ATENCAO"###"Não foram encontradas atualizações necessárias para utilização desta rotina, favor atualizar o repositório."
	Help( " ", 1, OemToAnsi(STR0007),, cMsgDesatu, 1, 0 )
	Return 																	
EndIf

//Primeiro parâmetro da VldRotTab, quais eventos validar {S-1005, S-1010, S-1020}
If !VldRotTab({.T.,.F.,.F.},@aDados)
	Help( " ", 1, OemToAnsi(STR0007),, CRLF + aDados[1] + CRLF + CRLF + OemToAnsi(STR0019) + CRLF + OemToAnsi(STR0020), 1, 0) //Atenção # O compartilhamento da tabela (RJ4) e (C92) estão divergentes, altere o modo de acesso através do Configurador. Arquivos (RJ4) e (C92)
	//O modo de acesso deve ser o mesmo para todas as tabelas envolvidas no processo, são elas: RJ3, RJ4, RJ5, RJ6, C99 e C92."
	Return
EndIf

oBrwRJ4 := FWmBrowse():New()		
oBrwRJ4:SetAlias( 'RJ4' )
oBrwRJ4:SetDescription( STR0001 )   // "Obras Próprias eSocial"

//Filtro padrao do Browse conforme tabela RJ4 (OBRAS PROPRIAS ESOCIAL)
oBrwRJ4:SetFilterDefault(cFiltraRh)
oBrwRJ4:Activate()    

Return( Nil )


//-------------------------------------------------------------------
/*/{Protheus.doc} function MenuDef
Rotina para definir o menu de rotinas 
@author  Gisele Nuncherino
@since   20/03/19
@version V 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
	
	ADD OPTION aRotina Title STR0002  Action 'PesqBrw'			OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina Title STR0003  Action 'VIEWDEF.GPEA934A'	OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina Title STR0004  Action 'VIEWDEF.GPEA934A'	OPERATION 3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina Title STR0005  Action 'VIEWDEF.GPEA934A'	OPERATION 4 ACCESS 0 //"Atualizar"
	ADD OPTION aRotina Title STR0006  Action 'VIEWDEF.GPEA934A'	OPERATION 5 ACCESS 0 //"Excluir"
	
Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} function ModelDef
Rotina para definir o modelo a ser utilizado 
@author  Gisele Nuncherino
@since   20/03/19
@version V 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()	
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruRJ4 := FWFormStruct( 1, 'RJ4', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel
      
// Blocos de codigo do modelo
Local bPosValid 	:= { |oModel| GP394POSVAL( oModel ) }
Local bCommit 	    := { |oModel| GP934AGRV( oModel )   }

//Variável que define se deve enviar eventos conforme a nota técnica 15/2019
Local lNT15			:= .F.

fVersEsoc("S1005", .F., Nil, Nil, Nil, Nil ,Nil, @lNT15)

oStruRJ4:SetProperty( 'RJ4_TPINSC' , MODEL_FIELD_WHEN , {||.F.})

// Inicializa campos
oStruRJ4:SetProperty( "RJ4_TPINSC", MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "'4'" ) )

If lNT15
	oStruRJ4:SetProperty( "RJ4_APR", MODEL_FIELD_OBRIGAT, .F. )
EndIf

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('GPEA934A', /*bPreValid*/, bPosValid, bCommit, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'GPEA934A_MRJ4', /*cOwner*/, oStruRJ4, /*bLOkVld*/, /*bTOkVld*/, /*bCarga*/ )

// Adiciona a descricao do Componente do Modelo de Dados
oModel:SetDescription( STR0001 )   //"Obras Próprias eSocial"

//--Valida se o model deve ser ativado
oModel:SetVldActivate( { |oModel| fVldModel(oModel,oModel:GetOperation()) } )
	
Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} function ViewDef
Rotina para definir a view a ser utilizada
@author  Gisele Nuncherino
@since   20/03/19
@version V 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'GPEA934A' )

// Cria a estrutura a ser usada na View
Local oStruRJ4 := FWFormStruct( 2, 'RJ4' )
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

oStruRJ4:SetProperty( 'RJ4_TPINSC', MVC_VIEW_TITULO, "Tp. Insc. CNO")
oStruRJ4:SetProperty( 'RJ4_NINSCR', MVC_VIEW_TITULO, "Num. Insc. CNO")
oStruRJ4:SetProperty( 'RJ4_PRC', MVC_VIEW_TITULO, "Num. Proc Isen. Aprend.")

//Adiciona Grid na interface
oView:AddField( 'GPEA934A_VRJ4', oStruRJ4, 'GPEA934A_MRJ4' )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} function GP394POSVAL
Rotina para validar as informações antes de serem gravadas na base de
Dados
@author  Gisele Nuncherino
@since   20/03/19
@version V 1.0
/*/
//-------------------------------------------------------------------
Static Function GP394POSVAL( oModel )

	Local lRetorno 		:= .T.
	Local nOperation
	Local oMyMdl 		:= oModel:GetModel("GPEA934A_MRJ4")
	Local cChave    	:= ""
	Local lNT15			:= .F.
	Local oViewAux		:= FWViewActive()
	Local lCposRatFap	:= (oViewAux:HasField("GPEA934A_VRJ4","RJ4_TPRAT") .And. oViewAux:HasField("GPEA934A_VRJ4","RJ4_TPFAP"))

	// Seta qual e a operacao corrente
	nOperation := oModel:GetOperation()

	If nOperation == MODEL_OPERATION_INSERT .or. ( nOperation == MODEL_OPERATION_UPDATE .and. (oMyMdl:GetValue('RJ4_INI') + oMyMdl:GetValue('RJ4_TPINSC') + oMyMdl:GetValue('RJ4_NINSCR') <> RJ4->(RJ4_INI + RJ4_TPINSC + RJ4_NINSCR) ))
		fVersEsoc("S1005", .F., Nil, Nil, Nil, Nil ,Nil, @lNT15)
		cChave := oMyMdl:GetValue('RJ4_INI') + oMyMdl:GetValue('RJ4_TPINSC') + oMyMdl:GetValue('RJ4_NINSCR')
		
		dbSelectArea( "RJ4" )
		If dbSeek(xFilial("RJ4") + cChave ,.F.)			
			Help( ' ' , 1 , OemToAnsi(STR0007) , ,  OemToAnsi(STR0010) , 2 , 0 , , , , , , {  OemToAnsi(STR0011) } )
			lRetorno := .F.		
		EndIf

		IF lRetorno 
			IF oMyMdl:GetValue('RJ4_APR') == "1" .AND. EMPTY(oMyMdl:GetValue('RJ4_PRC'))
				Help( ' ' , 1 , OemToAnsi(STR0007) , , OemToAnsi(STR0012) , 2 , 0 , , , , , , { OemToAnsi(STR0013) } )//"Número do Processo (RJ4_PRC) deve ser informado quando o campo Contrata Aprendiz (RJ4_APR) estiver como '3'"
				lRetorno := .F.	
			ELSEIF !lNT15 .And. oMyMdl:GetValue('RJ4_APR') $ "1/2" .AND. EMPTY(oMyMdl:GetValue('RJ4_EED'))
				Help( ' ' , 1 , OemToAnsi(STR0007) , , OemToAnsi(STR0014) , 2 , 0 , , , , , , { OemToAnsi(STR0015) } )//"Entidade Educativa (RJ4_EED) é obrigatório quando o campo Contrata Aprendiz (RJ4_APR) for igual a '1' ou '2'"          
				lRetorno := .F.	        
			EndIf
			
		EndIf
	EndIf    

	If lRetorno .And. lCposRatFap .And. (nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE)
		lRetorno := fVldRatFap(oMyMdl)
	EndIf

Return( lRetorno )


//-------------------------------------------------------------------
/*/{Protheus.doc} function fVldModel
Rotina para ativar o model definido 
@author  Gisele Nuncherino
@since   20/03/19
@version V 1.0
/*/
//-------------------------------------------------------------------
Static Function fVldModel( oModel, nOperation )

Local lRetorno 	:= .T.
Local oMyMdl 	:= oModel:GetModel("GPEA934A_MRJ4")

Return( lRetorno )


//-------------------------------------------------------------------
/*/{Protheus.doc} function GP934AGRV
Rotina para gravas as informações na base de dados 
@author  Gisele Nuncherino
@since   20/03/19
@version V 1.0
/*/
//-------------------------------------------------------------------
Static Function GP934AGRV(oModel)
Local lRet       	:= .T.
Local aArea      	:= GetArea()
Local ASM0			:= FWLoadSM0(.T.,,.T.)
Local nOperation 	:= 0
Local cStatus		:= ""	
Local cAnoMesP  	:= "" 
Local aErros		:= {}
Local aInfoC		:= {}
Local cMsgErro		:= ""
Local cMesAnoP		:= ""
Local oMdl 			:= oModel:GetModel("GPEA934A_MRJ4")
Local cChave		:= ""
Local cTpInsc		:= ""
Local aInfo			:= {}
Local nV			:= 1
Local lRetorno      := .T.
Local cEFDAviso	    := If(cPaisLoc == 'BRA' .And. Findfunction("fEFDAviso"), fEFDAviso(), SuperGetMv("MV_EFDAVIS",, "0")) 
local nErro			:= 0
Local cChave		:= ""
Local cStatRJE		:= "-1"
Local cTpInsc1      := ""
Local lAdmPubl1     := .F.
Local cNrInsc1	    := ""
Local cFilEmp       := ""
Local lVld1000		:= .T.
Local cStat1005     := ""
Local lNT15			:= .F.
Local cVersEnvio	:= ""
Local lAlt			:= .F.

	IF lRetorno 
        fVersEsoc("S1005", .F., Nil, Nil, @cVersEnvio, Nil ,Nil, @lNT15)
		IF oMdl:GetValue('RJ4_APR') == "1" .AND. EMPTY(oMdl:GetValue('RJ4_PRC'))
            lRetorno := .F.
            nErro ++	
            
        ELSEIF !lNT15 .And. oMdl:GetValue('RJ4_APR') $ "1/2" .AND. EMPTY(oMdl:GetValue('RJ4_EED'))
            lRetorno := .F.
            nErro ++
		EndIf
    EndIf
    	
	// Seta qual e a operacao corrente
	nOperation := oModel:GetOperation()
	
	If nErro > 0 .And. cEFDAviso $ "0|2"  
		FWFormCommit(oModel)
		RETURN(lRet)
	Endif  
	
	//Se a versão de envio for 9.00.00 (S-1.0) verifica se houve alteração em algum campo que gera o XML
	If cVersEnvio >= "9.0.00" .And. nOperation == 4
		lAlt := fCpoAlt(oModel)
	EndIf
	
	If cVersEnvio < "9.0.00" .Or. lAlt .Or. nOperation <> 4 
		If lMiddleware .and. !ChkFile("RJE") .And. !ChkFile("RJ9")
			MSGInfo(STR0024,STR0007) //#"Tabela RJ9 e RJE não encontrada. Execute o UPDDISTR - atualizador de dicionário e base de dados." # "Atenção"
			Return(lRet)                                                                                                                                                                                                                                                                                                                                                                                                                
		Else
		
       			cTpInsc	:= oMdl:GetValue('RJ4_TPINSC')
	
				cAnoMesP:= oMdl:GetValue('RJ4_INI')
				
				cMesAnoP := SUBSTR(oMdl:GetValue('RJ4_INI'),5,2) + SUBSTR(oMdl:GetValue('RJ4_INI'),1,4)
	
				If lMiddleware
					lVld1000 := fVld1000( AnoMes(dDataBase), @cStatRJE )
					
					If lVld1000
					
						aInfoC   := fXMLInfos()
								
						IF LEN(aInfoC) >= 4
							cTpInsc1  := aInfoC[1]
							lAdmPubl1 := aInfoC[4]
							cNrInsc1  := aInfoC[2]
						ELSE
							cTpInsc1  := ""
							lAdmPubl1 := .F.
							cNrInsc11  := "0"
						ENDIF
					
						cChave  := cTpInsc1 + PADR( Iif( !lAdmPubl1 .And. cTpInsc1 == "1", SubStr(cNrInsc1, 1, 8), cNrInsc1), 14 ) + "S1005" + Padr(xFilial("RJ4") + oMdl:GetValue('RJ4_NINSCR'), fTamRJEKey(), " ") + Substr(cMesAnoP,3,4)+ Substr(cMesAnoP,1,2)
						cStat1005 := "-1"
						GetInfRJE( 2,cChave,@cStat1005)
						cStatus := cStat1005
					Else
						lRet := .F.
						cMsgRJE := OemtoAnsi(STR0026)
						do Case 
							case cStatRJE == "-1" // nao encontrado na base de dados
								cMsgRJE := OemtoAnsi(STR0027) //"Registro do evento S-1000 não localizado na base de dados"
							case cStatRJE == "1" // nao enviado para o governo
								cMsgRJE := OemtoAnsi(STR0028) //"Registro do evento S-1000 não transmitido para o governo"
							case cStatRJE == "2" // enviado e aguardando retorno do governo
								cMsgRJE := OemtoAnsi(STR0029) //"Registro do evento S-1000 aguardando retorno do governo"
							case cStatRJE == "3" // enviado e retornado com erro 
								cMsgRJE := OemtoAnsi(STR0030) //"Registro do evento S-1000 retornado com erro do governo"
							endcase
							// Se tornar impeditivo o prosseguimento devido a presenca de inconsistencias
							If cEFDAviso == "0"
								oModel:SetErrorMessage("",,oModel:GetId(),"","",cMsgRJE)    
								lRet := FWFormCommit(oModel)
								Return lRet
							elseIf cEFDAviso == "1"
								lRet := .F.
								oModel:SetErrorMessage("",,oModel:GetId(),"","",cMsgRJE)
								
								Return lRet
							Endif			
					Endif
				Else
					//TPINSC + NRINSC +  DTINI
					cStatus := TAFGetStat( "S-1005", cTpInsc + ";" + RJ4->RJ4_NINSCR + ";" + cMesAnoP)
				EndIf
				
				IF cStatus == "4" // JA INTEGRADO COM Middleware
	
					if nOperation == 3 // inclusao
					 	If lMiddleware
					 		aErros := MontaXML(nOperation,oMdl)
					 	Else
					 		MsgAlert(OemToAnsi(STR0016))
					 	EndIf
						
						If Len( aErros ) <= 0
							If lMiddleware
							   MsgAlert(OemToAnsi(STR0025))
							  // MsgAlert(OemToAnsi(STR0018))
							  lRet :=	.T.
							Else
							   MsgAlert(OemToAnsi(STR0017))
							
							   MsgAlert(OemToAnsi(STR0018))
							   /*
								A Chave dos eventos de tabela é composta pelo código da tabela e a data de início da vigência. 
								Importante observar que, se informar uma data que já exista no fechamento da folha, 
								será necessário reabrir a folha de pagamento (evento S-1298) e 
								retificar os eventos periódicos (S-1200 e S-1210)
							   */
							   lRet :=	.F. 
							EndIf
						else
							oModel:SetErrorMessage("",,oModel:GetId(),"","",aErros[1])
							lRet := .F.
						EndIf
						 
					elseif nOperation == 4 // alteracao
						
						aErros := MontaXML(nOperation,oMdl)
						
						If Len( aErros ) <= 0
							If lMiddleware
							   MsgAlert(OemToAnsi(STR0025))
							  // MsgAlert(OemToAnsi(STR0018))
							  lRet :=	.T.
							Else
							   MsgAlert(OemToAnsi(STR0017))
							
							   MsgAlert(OemToAnsi(STR0018))
							   lRet :=	.F. 
							EndIf
						else
							oModel:SetErrorMessage("",,oModel:GetId(),"","",aErros[1])
							lRet := .F.
						EndIf
					 elseif nOperation == 5 // exclusao
						If !( cStatus $ " |1|3|-1" )
							
								aErros := MontaXML(nOperation,oMdl)
							
							
							If Len( aErros ) <= 0
								If lMiddleware
									MsgAlert(OemToAnsi(STR0031))
								Else
									MsgAlert(OemToAnsi(STR0017))
								EndIf
								
							else
								FeSoc2Err( aErros[1], @cMsgErro , Iif( aErros[1]!='000026',1,2 ) )
								If lMiddleware
									oModel:SetErrorMessage("",,oModel:GetId(),"","",aErros[1])
									lRet := .T.
								Else
									MsgAlert(aErros[1] + " - " + cMsgErro)
									lRet :=	.F.
								EndIf
								
													
							EndIf
						EndIf
						lRet :=	FWFormCommit(oModel)
					 EndIf
				 ELSE
					if nOperation == 3 .or. nOperation == 4 // inclusao ou alteracao 
							
						if cStatus == "-1"//Registro não encontrado  
							nOperation := 3 // inclusao 
						else 
							
							nOperation := 4 //alteracao
						Endif
						
						aErros := MontaXML(nOperation,oMdl)
					
						If Len( aErros ) <= 0
							If lMiddleware
								MsgAlert(OemToAnsi(STR0031))//STR0017))
								lRet :=	.T.
							Else
								MsgAlert(OemToAnsi(STR0017))
							EndIf
						Else
							FeSoc2Err( aErros[1], @cMsgErro , Iif( aErros[1]!='000026',1,2 ) )
							If lMiddleware
								oModel:SetErrorMessage("",,oModel:GetId(),"","",aErros[1])
								lRet := .F.
							Else
								MsgAlert(aErros[1] + " - " + cMsgErro)
								lRet :=	.F.
							Endif
						EndIf
					elseif nOperation == 5 // exclusao
						
						aErros := MontaXML(nOperation,oMdl)
						
						If Len( aErros ) <= 0
							If lMiddleware
								MsgAlert(OemToAnsi(STR0031))//STR0017))
								lRet :=	.T.
								
							Else
								MsgAlert(OemToAnsi(STR0017))
								lRet :=	.T.
							EndIf
						Else
							FeSoc2Err( aErros[1], @cMsgErro , Iif( aErros[1]!='000026',1,2 ) )
							If lMiddleware
								oModel:SetErrorMessage("",,oModel:GetId(),"","",aErros[1])
								lRet := .F.
							Else
								MsgAlert(aErros[1] + " - " + cMsgErro)
								lRet :=	.F.
							Endif
						EndIf
					EndIf	
				EndIf
			Endif
	EndIf

	if lRet
		lRet := FWFormCommit(oModel)
	EndIf	
RestArea( aArea )

Return lRet


Static Function MontaXML(nOperation,oMdl)

Local aEstObras		:= {}
Local cCnae			:= ""
Local cSubPat		:= "" 
Local aErros		:= {}
Local cMsgErro		:= ""
Local nCont			:= 0
Local cResumo		:= ""
Local lRetTaf		:= .F.
Local cMesAnoP		:= ""
Local aTabS120		:= {}
Local nPos1			:= 0
Local aEstEd		:= {}
Local oViewAux		:= FWViewActive()
Local lCposRatFap	:= (oViewAux:HasField("GPEA934A_VRJ4","RJ4_TPRAT") .And. oViewAux:HasField("GPEA934A_VRJ4","RJ4_TPFAP"))
Local lCNPJR		:= RJ4->(ColumnPos("RJ4_CNPJR")) > 0
Local cCNPJR		:= ""

cTpInsc	:= oMdl:GetValue('RJ4_TPINSC')

cCnae	:= oMdl:GetValue('RJ4_CNAE')

cAnoMesP:= oMdl:GetValue('RJ4_INI')

cMesAnoP := SUBSTR(oMdl:GetValue('RJ4_INI'),5,2) + SUBSTR(oMdl:GetValue('RJ4_INI'),1,4)
If lCNPJR
	cCNPJR:= oMdl:GetValue('RJ4_CNPJR')
Endif

//Busca informacao SubPatronal
cSubPat := ""

If oMdl:GetValue('RJ4_TPINSC') == "4"
	cSubPat := oMdl:GetValue('RJ4_ISC')
EndIf

If Len(aEstEd) == 0  // so deve carregar uma vez este array
	
	fCarrTab( @aTabS120, "S120",/*dDataRef*/,.T.,/*cAnoMes*/,/*lCarNew*/,cFilant)
	nPos1	:= Ascan(aTabS120,{|x| x[2] == cFilant })
	If nPos1 > 0
		If (Alltrim(aTabS120[nPos1,2]) == Alltrim(cFilant) .Or. Empty(aTabS120[nPos1, 2]) ).And. Empty(aTabS120[nPos1,6])
			Aadd(aEstEd, {aTabS120[nPos1,7], aTabS120[nPos1,2]} )
		Endif
	EndIf
EndIf
		
	Aadd(aEstObras, {	oMdl:GetValue("RJ4_FILIAL")							, ;	//01 Filial
						oMdl:GetValue("RJ4_TPINSC")							, ;	//02 TIPO2 / Tipo Inscrição
						oMdl:GetValue("RJ4_NINSCR")							, ;	//03 CEI2  / Num Inscrição
						""													, ;	//04 FPAS
						""													, ;	//05 Cod. Terceiro
						cCnae												, ;	//06 CNAE
						oMdl:GetValue("RJ4_RAT")							, ;	//07 RAT
						oMdl:GetValue("RJ4_FAP")							, ;	//08 FAP
						oMdl:GetValue("RJ4_FAP") *  oMdl:GetValue("RJ4_RAT"), ;	//09 % Acidente de Trabalho
						oMdl:GetValue("RJ4_NINSCR")							, ;	//10 Número da Inscrição (Utilizado para buscar a entidade educativa, na fCarrCTT)
						cSubPat												, ;	//11 Subst. Contrib. Patronal
						oMdl:GetValue("RJ4_PON")							, ;	//12 Tipo de Ponto
						oMdl:GetValue("RJ4_APR")							, ;	//13 Contrata Aprendiz
						oMdl:GetValue("RJ4_PRC")							, ;	//14 Número do Processo Aprendiz
						oMdl:GetValue("RJ4_EED")							, ;	//15 Tipo de Entidade Educativa
						oMdl:GetValue("RJ4_INI")							, ;	//16 Mes Ano
						nOperation											, ;	//17 nOpc
						oMdl:GetValue("RJ4_INI")	 						, ;	//18 Data Inicial(MMAAAA)
						Iif(lCposRatFap, oMdl:GetValue("RJ4_TPRAT"), "")	, ;	//19 Tipo do Processo (1-Administrativo, 2-Judicial)
						Iif(lCposRatFap, oMdl:GetValue("RJ4_NPRAT"), "")	, ;	//20 Número do Processo
						Iif(lCposRatFap, oMdl:GetValue("RJ4_SURAT"), "")	, ; //21 Código do Indicativo da Suspensão
						Iif(lCposRatFap, oMdl:GetValue("RJ4_TPFAP"), "")	, ;	//22 Tipo do Processo (1-Administrativo, 2-Judicial, 4-Processo FAP)
						Iif(lCposRatFap, oMdl:GetValue("RJ4_NPFAP"), "")	, ;	//23 Número do Processo
						Iif(lCposRatFap, oMdl:GetValue("RJ4_SUFAP"), "")	, ; //24 Código do Indicativo da Suspensão
						cCNPJR												} ) //25 CNPJ Responsavel


	lRetTaf := fCarrCTT(aEstObras, cMesAnoP, aEstEd, @aErros, cFilant, nOperation, 1 )


Return aErros
				
Function fGerarRJE(aEstObras, cMesAnoP, aEstEd, aErros, cFilEnv, nOpc, cXml, lContinua,aID,cFunc,nValor)
Local aArea 		:= GetArea()
Local cAliasRJ4		:= GetNextAlias()
Local aSM0			:= FwLoadSM0(.T.,,.T.)
Local cStatRJE		:= "-1"
Local cOperRJE		:= "I"
Local cRetfRJE      := "1"
Local cStatOld      := ""
Local cOperOld		:= ""
Local cRetfOld		:= ""
Local cStat1005		:= "-1"
Local cOper1005		:= "I"
Local cRetf1005     := "1"
Local nRec1005		:= 0
Local cRetfNew		:= ""
Local cStatNew		:= ""
Local cOperNew		:= ""
lOCAL cChave1005    := ""
Local cPeriodo		:= ""

Local cHrGer		:= Time()
Local dDtGer		:= Date()
Local nAliqRatAjust := 0
Local nOpcao		:= 3
Local nOperation	:= 0
Local nRecOld		:= 0
Local nRecRJE		:= 0
lOCAL cFilEmp       := ""
Local nFilEmp		:= 0
	
Local lAdmPubl		:= .F.
Local lContinua		:= .T.
Local lSemFilial 	:= .F.
Local lNovoRJE		:= .F.
Local lRet			:= .T.
Local lVld1000		:= .T.
Local nDtIni		:= ""

Local cTpInsc		:= ""
Local cNrInsc		:= ""
Local cChvFil		:= ""

Default oModel		:= Nil
Default aErros		:= {}
Default aDados		:= {}
Default nValor		:= 1
DEFAULT nID			:= 1

If lContinua 
	
	lVld1000 := fVld1000( AnoMes(dDataBase), @cStatRJE )
	//	* 1 - Não enviado - Gravar por cima do registro encontrado
	//	* 2 - Enviado - Aguarda Retorno - Enviar mensagem em tela e não continuar com o processo
	//	* 3 - Retorno com Erro - Gravar por cima do registro encontrado
	//	* 4 - Retorno com Sucesso -?Efetivar a gravação
	
	aInfoC   := fXMLInfos()
						
	IF LEN(aInfoC) >= 4
		cTpInsc	 := aInfoC[1]
		lAdmPubl := aInfoC[4]
		cNrInsc  := aInfoC[2]
	ELSE
		cTpInsc  := ""
		lAdmPubl := .F.
		cNrInsc1  := "0"
	ENDIF
			
	If ( nFilEmp := aScan(aSM0, { |x| x[1] == cEmpAnt .And. X[18] == cNrInsc }) ) > 0
		cFilEmp := aSM0[nFilEmp, 2]
	Else
		cFilEmp := cFilAnt
	EndIf
	
	If IsInCallStack("GPEA934A")
		cChvFil := xFilial("RJ4", cFilEnv)
	ElseIf IsInCallStack("fIntExt005") .Or. cFunc == "X14"
		cChvFil	:= cFilEnv
	Else
		cChvFil := xFilial("CTT", cFilEnv)
	EndIf		
						   
	cChave  := cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14 ) + "S1005" + Padr(cChvFil + IIF(cFunc == "X14", aEstObras[nValor,2], aEstObras[nValor,3]), fTamRJEKey(), " ") + Substr(cMesAnoP,3,4)+ Substr(cMesAnoP,1,2)
	GetInfRJE( 2,cChave,@cStat1005,@cOper1005,@cRetf1005,@nRec1005)	
	
	If lVld1000
	
		//Verifico o status de envio o registro S-1005 anterior
		If nOpc == 4
			cStatOld 	:= cStat1005
			cOperOld 	:= cOper1005
			cRetfOld 	:= cRetf1005
			nRecOld 	:= nRec1005
			//Não existe na fila, será tratado como inclusão
			If cStat1005 == "-1"
				nOpcao 		:= 3
				cOperNew 	:= "I"
				cRetfNew	:= "1"
				cStatNew	:= "1"
				lNovoRJE	:= .T.
			ElseIf cStatOld $ "1/3"
				cStat1005 := cStatOld
				cOper1005 := cOperRJE
				cRetf1005 := cRetfOld
				nRec1005  := nRecOld
			EndIf
		Endif
		
		If nOpc == 3 .And. funName() == "GPEM023"
			cStatOld 	:= cStat1005
			cOperOld 	:= cOper1005
			cRetfOld 	:= cRetf1005
			nRecOld 	:= nRec1005
			//Não existe na fila, será tratado como inclusão
			If cStat1005 == "-1"
				nOpcao 		:= 3
				cOperNew 	:= "I"
				cRetfNew	:= "1"
				cStatNew	:= "1"
				lNovoRJE	:= .T.
			ElseIf cStatOld $ "1/3"
				cStat1005 := cStatOld
				cOper1005 := cOperRJE
				cRetf1005 := cRetfOld
				nRec1005  := nRecOld
			EndIf	
		Endif
		
		//Alteração ou exclusão
		If nOpc == 4 .Or. nOpc == 5
			//Retorno pendente impede o cadastro
			If cStat1005 == "2"
				aErros 	:= {STR0032}//STR0020//"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"
				lRet		:= .F.
			EndIf
			//Alteração
			If nOpc == 4
				//Evento de exclusão sem transmissão impede o cadastro
				If cOper1005 == "E" .And. cStat1005 != "4"
					aErros 	:={STR0033}// STR0021//"Operação não será realizada pois há evento de exclusão que não foi transmitido ou está com retorno pendente"
					lRet		:= .F.
				//Evento sem transmissão, irá sobrescrever o registro na fila
				ElseIf cStat1005 $ "1/3"
					If cOper1005 == "A"
						nOpcao 	:= 4
					EndIf
					cOperNew 	:= cOper1005
					cRetfNew	:= cRetf1005
					cStatNew	:= "1"
					lNovoRJE	:= .F.
				//Evento diferente de exclusão transmitido, irá gerar uma retificação
				ElseIf cOper1005 != "E" .And. cStat1005 == "4"
					nOpcao 		:= 4
					cOperNew 	:= "A"
					cRetfNew	:= "2"
					cStatNew	:= "1"
					lNovoRJE	:= .T.
				//Evento de exclusão transmitido, será tratado como inclusão
				ElseIf cOper1005 == "E" .And. cStat1005 == "4"
					nOpcao 		:= 3
					cOperNew 	:= "I"
					cRetfNew	:= "1"
					cStatNew	:= "1"
					lNovoRJE	:= .T.
				EndIf
			//Exclusão
			ElseIf nOpc == 5
				nOpcao 		:= 5
				//Evento de exclusão sem transmissão impede o cadastro
				If cOper1005 == "E" .And. cStat1005 != "4"
					aErros 	:= {STR0033}//STR0021//"Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"
					lRet		:= .F.
				//Evento diferente de exclusão transmitido irá gerar uma exclusão
				ElseIf cOper1005 != "E" .And. cStat1005 == "4"
					cOperNew 	:= "E"
					cRetfNew	:= cRetf1005
					cStatNew	:= "1"
					lNovoRJE	:= .T.
				EndIf
			Endif
		//Inclusão
		ElseIf nOpc == 3 .And. funName() <> "GPEM023D" .And. cStat1005 == "-1"
			cOperNew 	:= "I"
			cRetfNew	:= "1"
			cStatNew	:= "1"
			lNovoRJE	:= .T.
		ElseIf nOpc == 3 .And. cStat1005 $ "1/3" .And. cOper1005 <> "A" //Carga Inicial
			cOperNew 	:= "I"
			cRetfNew	:= "1"
			cStatNew	:= "1"
			lNovoRJE	:= .F.
		ElseIf nOpc == 3 .And. cStat1005 $ "1/3"//Carga Inicial
			cOperNew 	:= "I" 
			cRetfNew	:= "1"
			cStatNew	:= "1"
			lNovoRJE	:= .F.	
		ElseIf nOpc == 3 .And. cStat1005 $ "2"
			aErros 	:= {STR0032}//STR0020//"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"
			lRet		:= .F.
		ElseIf nOpc == 3 .And. cStat1005 $ "4" //Carga Inicia
			cOperNew 	:= "A"
			cRetfNew	:= "2"
			cStatNew	:= "1"
			lNovoRJE	:= .T.
		EndIf
		
		If lRet
			aAdd( aDados, { xFilial("RJE", cFilEnv), cChvFil, aID[nID,5], Iif( aID[nID,5] == "1", SubStr(aID[nID,6], 1, 8), aID[nID,6]), "S1005", Substr(cMesAnoP,3,4)+ Substr(cMesAnoP,1,2), aID[nID,7], aID[nID,1], cRetfNew, "12", cStatNew, aID[nID,3], aID[nID,4], cOperNew } )
			
			//Se não for uma exclusão de registro não transmitido, cria/atualiza registro na fila
			If !( nOpcao == 5 .And. ((cOper1005 == "E" .And. cStat1005 == "4") .Or. cStat1005 $ "-1/1/3") )
				If !( lRet := fGravaRJE( aDados, cXml, lNovoRJE, nRec1005 ) )
					aErros := {STR0034}//STR0022//"Ocorreu um erro na gravação do registro na tabela RJE"
				EndIf
			//Se for uma exclusão e não for de registro de exclusão transmitido, exclui registro de exclusão na fila
			ElseIf nOpcao == 5 .And. cStat1005 != "-1" .And. !(cOper1005 == "E" .And. cStat1005 == "4")
				If !( lRet := fExcluiRJE( nRec1005 ) )
					aErros := {STR0035} //STR0023//"Ocorreu um erro na exclusão do registro na tabela RJE"
				EndIf
			EndIf
		Endif
		Else
			lRet := .T.
			cMsgRJE := OemtoAnsi(STR0026)
			do Case 
				case cStatRJE == "-1" // nao encontrado na base de dados
					aErros := {OemtoAnsi(STR0027)} //"Registro do evento S-1000 não localizado na base de dados"
				case cStatRJE == "1" // nao enviado para o governo
					aErros := {OemtoAnsi(STR0028)} //"Registro do evento S-1000 não transmitido para o governo"
				case cStatRJE == "2" // enviado e aguardando retorno do governo
					aErros := {OemtoAnsi(STR0029)} //"Registro do evento S-1000 aguardando retorno do governo"
				case cStatRJE == "3" // enviado e retornado com erro 
					aErros := {OemtoAnsi(STR0030)} //"Registro do evento S-1000 retornado com erro do governo"
				endcase
				// Se tornar impeditivo o prosseguimento devido a presenca de inconsistencias
				If cEFDAviso == "0"
					//if FunName() <> "GPEA934A"
						//MsgInfo(cMsgRJE,OemToAnsi(STR0007))
					//EndIf
					lRetorno		:= .T. 
				elseIf cEFDAviso == "1"
					lRetorno := .F.
					//if FunName() <> "GPEA934A"
						//MsgInfo(cMsgRJE,OemToAnsi(STR0007))
					//EndIf
				Endif				
	Endif
EndIf	
	
Return ( lRet )

/*/{Protheus.doc} fVldRatFap
Função que valida o preenchimento dos campos das abas Processo RAT e Processo FAP
@type		Static Function
@author		Silvio C. Stecca
@since		28/02/2020
@version	12
@param 		oModel, objeto, objeto contendo informações do model
@return		lRet, logico, retorna .T. ou .F.
/*/
Static Function fVldRatFap(oModel)

	Local lRet := .T.

	Do Case
		Case !Empty(oModel:GetValue("RJ4_TPRAT")) .And. (Empty(oModel:GetValue("RJ4_NPRAT")) .Or. Empty(oModel:GetValue("RJ4_SURAT")))
			Help(' ', 1, OemToAnsi(STR0007),, + CRLF + OemToAnsi(STR0036), 2, 0,,,,,, {+ CRLF + OemToAnsi(STR0037)})//"Ao preencher algum campo referente ao Processo RAT, todos campos refente ao RAT devem ser preenchidos."
			lRet := .F.

		Case !Empty(oModel:GetValue("RJ4_NPRAT")) .And. (Empty(oModel:GetValue("RJ4_TPRAT")) .Or. Empty(oModel:GetValue("RJ4_SURAT"))) 
			Help(' ', 1, OemToAnsi(STR0007),, + CRLF + OemToAnsi(STR0036), 2, 0,,,,,, {+ CRLF + OemToAnsi(STR0037)})//"Ao preencher algum campo referente ao Processo RAT, todos campos refente ao RAT devem ser preenchidos."
			lRet := .F.
		
		Case !Empty(oModel:GetValue("RJ4_SURAT")) .And. (Empty(oModel:GetValue("RJ4_NPRAT")) .Or. Empty(oModel:GetValue("RJ4_TPRAT"))) 
			Help(' ', 1, OemToAnsi(STR0007),, + CRLF + OemToAnsi(STR0036), 2, 0,,,,,, {+ CRLF + OemToAnsi(STR0037)})//"Ao preencher algum campo referente ao Processo RAT, todos campos refente ao RAT devem ser preenchidos."
			lRet := .F.

		Case !Empty(oModel:GetValue("RJ4_TPFAP")) .And. (Empty(oModel:GetValue("RJ4_NPFAP")) .Or. Empty(oModel:GetValue("RJ4_SUFAP")))
			Help(' ', 1, OemToAnsi(STR0007),, + CRLF + OemToAnsi(STR0038), 2, 0,,,,,, {+ CRLF + OemToAnsi(STR0039)})//"Ao preencher algum campo referente ao Processo FAP, todos campos refente ao FAP devem ser preenchidos."
			lRet := .F.

		Case !Empty(oModel:GetValue("RJ4_NPFAP")) .And. (Empty(oModel:GetValue("RJ4_TPFAP")) .Or. Empty(oModel:GetValue("RJ4_SUFAP"))) 
			Help(' ', 1, OemToAnsi(STR0007),, + CRLF + OemToAnsi(STR0038), 2, 0,,,,,, {+ CRLF + OemToAnsi(STR0039)})//"Ao preencher algum campo referente ao Processo FAP, todos campos refente ao FAP devem ser preenchidos."
			lRet := .F.

		Case !Empty(oModel:GetValue("RJ4_SUFAP")) .And. (Empty(oModel:GetValue("RJ4_NPFAP")) .Or. Empty(oModel:GetValue("RJ4_TPFAP"))) 
			Help(' ', 1, OemToAnsi(STR0007),, + CRLF + OemToAnsi(STR0038), 2, 0,,,,,, {+ CRLF + OemToAnsi(STR0039)})//"Ao preencher algum campo referente ao Processo FAP, todos campos refente ao FAP devem ser preenchidos."
			lRet := .F.
	EndCase

Return lRet

/*/{Protheus.doc} fCpoAlt
Verifica se os campos de envio do evento na na versão S-1.0 foram alterados 
@since	22/01/2020
@autor	lidio.oliveira
@version 12
/*/
Static Function fCpoAlt(oModel)

Local oMdlRJ4 		:= oModel:GetModel("GPEA934A_MRJ4")
Local lAlterou  := .F.	
Local lCNPJR		:= RJ4->(ColumnPos("RJ4_CNPJR")) > 0
Local aArea		:= GetArea()
Local bCond     := {|x|(  RJ4->RJ4_INI <> oMdlRJ4:GetValue("RJ4_INI") ) .Or.;
( RJ4->RJ4_TPINSC <> oMdlRJ4:GetValue("RJ4_TPINSC") ) .Or.;
( RJ4->RJ4_NINSCR <> oMdlRJ4:GetValue("RJ4_NINSCR") ) .Or.;
( RJ4->RJ4_CNAE <> oMdlRJ4:GetValue("RJ4_CNAE") )  .Or.;
( RJ4->RJ4_RAT <> oMdlRJ4:GetValue("RJ4_RAT") ) .Or.;
( RJ4->RJ4_FAP <> oMdlRJ4:GetValue("RJ4_FAP") ) .Or.;
( RJ4->RJ4_PRC <> oMdlRJ4:GetValue("RJ4_PRC") ) .Or.;
( RJ4->RJ4_EED <> oMdlRJ4:GetValue("RJ4_EED") ) .Or.;
( RJ4->RJ4_TPRAT <> oMdlRJ4:GetValue("RJ4_TPRAT") ) .Or.;
( RJ4->RJ4_NPRAT <> oMdlRJ4:GetValue("RJ4_NPRAT") ) .Or.;
( RJ4->RJ4_SURAT <> oMdlRJ4:GetValue("RJ4_SURAT") ) .Or.;
( RJ4->RJ4_TPFAP <> oMdlRJ4:GetValue("RJ4_TPFAP") ) .Or.;
( RJ4->RJ4_NPFAP <> oMdlRJ4:GetValue("RJ4_NPFAP") ) .Or.;
( RJ4->RJ4_SUFAP <> oMdlRJ4:GetValue("RJ4_SUFAP") ) .Or.;
( If(lCNPJR, RJ4->RJ4_CNPJR <> oMdlRJ4:GetValue("RJ4_CNPJR"),.F.) )}

	If Eval( bCond )
		lAlterou := .T.
	Endif

	RestArea(aArea)

Return lAlterou
