#INCLUDE "PROTHEUS.CH"
#INCLUDE "PCOA009.CH"
#INCLUDE "XMLXFUN.CH"

#Define BMP_ON  "LBOK"
#Define BMP_OFF "LBNO"

Static lFWCodFil := .T.

Static nQtdEntid 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA009   บAutor  ณDaniel Leme         บ Data ณ  08/31/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPrograma para reprocessamento dos pontos de Integra็ใo      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCO                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOA009()
Private cCadastro	:= STR0001 //"Reprocessamento de Lan็amentos"
Private aRotina		:= MenuDef()
Private cMsgHelp	:= STR0010+CRLF+STR0024+CRLF+STR0025 //"Aten็ใo"###"Verifique o conte๚do do parโmetro MV_PCOINTE."###"Para qualquer integra็ใo, este parโmetro deverแ conter o valor 1"



	ProcLogIni( {}/*aButtons*/, "PCOA009" )

mBrowse(6,1,22,75,"AKB")


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA009DlgบAutor  ณDaniel Leme         บ Data ณ  08/07/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Dialog de reprocessamento                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOA009Dlg(cAlias,nRecnoAKB,nCallOpcx)
Local aRet			:= {}
Local aParametros	:= {}

Local aRetFil	:= {}
Local lRet		:= .F.
Local cFiltAMJ	:= ""
Local aAreaOri
Local cAliasEnt := GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM) //Alias()

//*********************************************
// variaves para reprocessamento Multi-Filial *
//*********************************************
Local cFilAtu	:= cFilAnt
Local nRegSM0	:= SM0->(Recno())
Local lMultFil	:= .F.
Local cFiltro
Local cProcess,cItem

Private lDelPeriodo
Private cFilialDe
Private cFilialAte
Private dPeriodoDe
Private dPeriodoAte
Private cFiltro009 // Filtro da Parambox mais o filtro da filial
Private lAgrupa

If SuperGetMV("MV_PCOINTE",.T.,"2") != "1"
	Help("   ",1,"PCOMVPCOINTE",,cMsgHelp,1,0)
	Return
EndIf

If Empty(cAliasEnt)
	Help("   ",1,"PCONOTABSX2",,STR0051,1,0) // "A tabela informada no campo AKB_ENTIDA nใo existe no dicionแrio de dados, verifique o cadastro em Atualiza็๕es > Lan็amentos > Pontos Lanc Integr."
	Return
EndIf

dbSelectArea("AL1")
dbSetOrder(1)
dbSelectArea("AL2")
dbSetOrder(1)
dbSelectArea("AK5")
dbSetOrder(1)
dbSelectArea("AMJ")
dbSetOrder(1)
dbSelectArea("AKS")
dbSetOrder(1)
dbSelectArea("AKT")
dbSetOrder(1)
dbSelectArea("ALA")
dbSetOrder(1)
dbSelectArea("AMK")
dbSetOrder(1)
dbSelectArea("AKB")

If AKB->AKB_PERMR == "1"
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ  Verifica se existem pontos de lancamentos para integracao configurados  ณ
	//ณ  e se existe existe pelo menos um ativo.                                 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	AMK->(DbSetOrder(1))
	If AMK->( DbSeek( xFilial("AMK")+AKB->AKB_PROCES+AKB->AKB_ITEM ) ) 
		While AMK->( !Eof() .And. AMK_PROCES+AMK_ITEM == AKB->(AKB_PROCES+AKB_ITEM) )
        	If AMK->AMK_ATIVO == "LBOK"
	        	lRet := .T.
	        	Exit
        	EndIF 
        	AMK->(DbSkip())	
        End
	EndIf
	
	If !lRet
		Help("   ",1,"PCONOLANCINTEGR",,STR0050,1,0) // "Nใo existem pontos de lan็amento para integra็ใo cadastrados, ou nใo existe nenhum ativo. Verifique a rotina em Atualiza็๕es > Lan็amentos > Pontos Lanc Integr."
		Return
	EndIF
    
	lRet := .F.

	If	FWModeAccess("AK8",3) == "C" .And.; 
		FWModeAccess("AKB",3) == "C" .And.;
		FWModeAccess("AMK",3) == "C"

		lMultFil := .T.
		aParametros := { 	{ 5, STR0004,.T.,120,,.F.},; //"Apagar lan็amantos do periodo ?"					
							{ 1, STR0022,IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ),"" 	 ,"Empty() .or. ExistCpo('SM0',cEmpAnt+mv_par02)"  ,"SM0"    ,"" ,50 ,.F. },; //"Filial de"
							{ 1, STR0023,IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ),"" 	 ,"MV_PAR03>='ZZ' .or. ExistCpo('SM0',cEmpAnt+mv_par03)"  ,"SM0"    ,"" ,50 ,.F. },; //"Filial ate"
							{ 1, STR0005,CTOD("  /  /  "),"" 	 ,""  ,""    ,"" ,50 ,.F. },; //"Periodo de"
							{ 1, STR0006,CTOD("  /  /  "),"" 	 ,""  ,""    ,"" ,50 ,.F. },; //"Periodo Ate"
							{ 7, STR0007+cAliasEnt,cAliasEnt,""},; //"Filtro "
							{ 5, STR0008,.T.,120,,.F.} } //"Agrupar pelas Ent. Orcamentแrias ?"

	Else

		aParametros := { 	{ 5, STR0004,.T.,120,,.F.},; //"Apagar lan็amantos do periodo ?"					
				   			{ 1, STR0005,CTOD("  /  /  "),"" 	 ,""  ,""    ,"" ,50 ,.F. },; //"Periodo de"
			  				{ 1, STR0006,CTOD("  /  /  "),"" 	 ,""  ,""    ,"" ,50 ,.F. },; //"Periodo Ate"
							{ 7, STR0007+cAliasEnt,cAliasEnt,""},; //"Filtro "
							{ 5, STR0008,.T.,120,,.F.} } //"Agrupar pelas Ent. Orcamentแrias ?"

	EndIf

	If ParamBox(aParametros,STR0009,aRet) //"Parametros"

		//*******************************
		// reprocessamento Multi-Filial *
		//*******************************
		If lMultFil
			lDelPeriodo			:= aRet[1]
			cFilialDe			:= aRet[2]
			cFilialAte			:= aRet[3]
			dPeriodoDe			:= aRet[4]
			dPeriodoAte			:= aRet[5]
			cFiltro				:= aRet[6]
			lAgrupa				:= aRet[7]
		Else
			lDelPeriodo			:= aRet[1]
			cFilialDe			:= cFilAnt
			cFilialAte			:= cFilAnt
			dPeriodoDe			:= aRet[2]
			dPeriodoAte			:= aRet[3]
			cFiltro				:= aRet[4]
			lAgrupa				:= aRet[5]
		EndIf	    

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Inicia o log de processamento  - nao tirar a linha abaixo  ณ
		//ณ pois funcao ProcLogIni utiliza as variaveis mv_par private ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		AEval( aRet, { |x,y| SetPrvt("MV_PAR"+AllTrim(STRZERO(y,2,0))), &("MV_PAR"+AllTrim(STRZERO(y,2,0))) := x } )

		If lDelPeriodo
			If Aviso(STR0010, STR0016, {STR0017, STR0018} )==1  //"Atencao"##"Filtrar os lancamentos existentes para exclusao do processo selecionado ?"##"Sim"##"Nao"
	
				If ParamBox( { { 7 , STR0007+STR0019,"AMJ",""} }, STR0009, aRetFil,,,,,,, "PCOA009_1", .F., .F.) //"Parametros"##"[ Excluir os Movimentos - AMJ ]"
					If !Empty(aRetFil[1])
						cFiltAMJ := aRetFil[1]
						lRet := .T.
					EndIf
				EndIf
	
				If !lRet
					Aviso(STR0010, STR0020, {"Ok"})  //"Atencao"##"Filtro nao informado. Operacao Cancelada!"
				EndIf	
				
				AEval( aRet, { |x,y| SetPrvt("MV_PAR"+AllTrim(STRZERO(y,2,0))), &("MV_PAR"+AllTrim(STRZERO(y,2,0))) := x } )
					
			Else
	
				If Aviso(STR0010, STR0021,{STR0017, STR0018} ) == 1  //"Atencao"##"Confirma a exclusao de todos os lancamentos para o processo selecionado?"##"Sim"##"Nao"
					lRet := .T.
				EndIf	
	
			EndIf
		Else
		   
			lRet	:= .T.
			
		EndIf

		If lRet
			//*******************************
			// reprocessamento Multi-Filial *
			//*******************************
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ  Backup da Area Anterior  ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			aAreaOri := GetArea()
						
			If !Empty(cAliasEnt)
				
				DbSelectArea("SM0")
		  		DbSeek(cEmpAnt+cFilialDe,.t.)
				While !SM0->(Eof()) .and. SM0->M0_CODIGO == cEmpAnt .and.	SM0->M0_CODFIL >= cFilialDe .and.; 
														 					SM0->M0_CODFIL <= cFilialAte
					cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
				
						ProcLogIni( {}/*aButtons*/, "PCOA009" )
			
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณ Atualiza o log de processamento   ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
						ProcLogAtu("INICIO")
	
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณ  Backup da Area SM0  ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					aAreaSM0 := GetArea()
					
					cFiltro009	:= ""
					If Empty(cFiltro)
					
						dbSelectArea(cAliasEnt)
						dbSetOrder(1)
					
						If  SubStr( cAliasEnt, 1, 1) == "S" 
							//se a primeira letra do alias for "S" entao	
							//considera campo filial a partir da segunda exemplo tabela SA1 - campo A1_FILIAL
							cFiltro009 :=SubStr( cAliasEnt, 2, 2 )+"_FILIAL=='"+xFilial(cAliasEnt)+"'"				
						Else			
							cFiltro009 :=cAliasEnt+"_FILIAL=='"+xFilial(cAliasEnt)+"'"
						EndIf
				    Else
						If ! ( "_FILIAL" $ cFiltro009 )
				    	
							If  SubStr( cAliasEnt, 1, 1) == "S" 
								//se a primeira letra do alias for "S" entao	
								//considera campo filial a partir da segunda exemplo tabela SA1 - campo A1_FILIAL
								cFiltro009 :=SubStr( cAliasEnt, 2, 2 )+"_FILIAL=='"+xFilial(cAliasEnt)+"' .And. "+cFiltro
							Else			
								cFiltro009 :=cAliasEnt+"_FILIAL=='"+xFilial(cAliasEnt)+"' .And. "+cFiltro
							EndIf
							
						EndIf
					EndIf
	
					If lDelPeriodo
		
						Processa({|| ProcDel(aRet, cFiltAMJ)}, STR0013, STR0014 )	// "Processando lan็amentos" ### "Excluindo lancamentos..."
								
					EndIf 
			
					If lRet
						Processa({|| lRet := ProcLanc(aRet)}, STR0013, STR0015 )		// "Processando lan็amentos" ### "Gerando lancamentos..."
					EndIf
					
					If !lRet
						Help("   ",1,"PCONOLACTO",,STR0056,1,0) // "Um ou mais campos nos pontos de lan็amentos de integra็ใo nใo estใo corretos. Verifique o tipo do campo informado."
						Exit
					EndIf
					
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณ Atualiza o log de processamento   ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
						ProcLogAtu("FIM")
		
					SM0->(DbSkip())
				EndDo
				DbSelectArea("SM0")
				DbGoTo(nRegSM0)
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ  Processamentos feitos, restaura a Area SM0 para continuar no loop e executar os registros restantes  ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				RestArea(aAreaSM0)				
				
			Else
			
				Help("   ",1,"PCONOTABELA",,STR0049,1,0) // "Tabela utilizada no Ponto de Lan็amento nใo ้ uma tabela vแlida, verifique o dicionแrio de dados."
				lRet := .F.
				
			EndIf // !Empty(cAliasEnt)
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ  Restaura a Area anterior para fazer os processamentos  ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			RestArea(aAreaOri)
	
			cFilAnt	:= cFilAtu
			
		EndIf // lRet
			
	EndIf // ParamBox()

Else
	Aviso(STR0010,STR0011,{STR0012},2) //"Aten็ใo"###"Este ponto nใo pode ser reprocessado"###"Fechar"
	lRet := .F.
EndIf

If lRet
	MsgInfo(STR0039) // "Arquivo Processado com Sucesso!"
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA009FilIntบAutor  ณMicrosiga           บ Data ณ  08/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCO                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A009FilInt(cProcesso,cItem,aRet)
Local lRet := .F.

Do Case
	Case cProcesso+cItem == "00025201"  // Inclusao de itens da Planilha
		lRet	:=	( AK2->AK2_DATAI >= dPeriodoDe .And. AK2->AK2_DATAF <= dPeriodoAte )
		If lRet	
			AK1->(dbSetOrder(1))
			lRet := ( AK1->(MsSeek(xFilial('AK1')+AK2->AK2_ORCAME)) .And. AK2->AK2_VERSAO == AK1->AK1_VERSAO ) 	
		Endif
	Case cProcesso+cItem == "00025202"  // Inclusao de itens da Planilha versoes revisadas
		lRet	:=	( AK2->AK2_DATAI >= dPeriodoDe .And. AK2->AK2_DATAF <= dPeriodoAte )
		If lRet	
			AKR->(dbSetOrder(1))
			AK1->(dbSetOrder(1))
			lRet := !( AKR->(MsSeek(xFilial('AKR')+AK2->AK2_ORCAME+AK2->AK2_VERSAO))).And.( AK1->(MsSeek(xFilial('AK1')+AK2->AK2_ORCAME)) .And. AK2->AK2_VERSAO <> AK1->AK1_VERSAO ) 
		Endif
	Case cProcesso+cItem == "00025203"  // Inclusao de itens da Planilha versoes simuladas
		lRet	:=	( AK2->AK2_DATAI >= dPeriodoDe .And. AK2->AK2_DATAF <= dPeriodoAte )
		If lRet	
			AKR->(dbSetOrder(1))
			lRet := ( AKR->(MsSeek(xFilial('AKR')+AK2->AK2_ORCAME+AK2->AK2_VERSAO)))
		Endif
	Case cProcesso+cItem == "00035801"  // Inclusao de movimentos de planejamento
		lRet	:=	( ALY->ALY_DTINI >= dPeriodoDe .And. ALY->ALY_DTFIM <= dPeriodoAte )

OtherWise 
	lRet := .T.
EndCase

Return lRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณProcDel   บAutor  ณMicrosiga           บ Data ณ  08/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCOA009                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ProcDel(aRet, cFiltAMJ, lXML)

Local cQuery		:= ""
Local cQryCond		:= ""
Local lResolvQry 	:= .F.
Local cFiltQry 	:= ""
Local cQryFim		:= ""
Local cCampos
Local dDatIni 		:= dPeriodoDe
Local dDatFim 		:= dPeriodoAte
Local cAliasQry
Local dDataAnt
Local nDias
Local nX, nMin, nMax

Default lXML := .F.

//-- Verifica se filtro digitado por usuario e resolvido na query
If !Empty(cFiltAMJ)
	cFiltQry := PcoParseFil(cFiltAMJ, "AMJ")
	If ! Empty(cFiltQry)
		lResolvQry 	:= .T.
	EndIf
Else
	lResolvQry 	:= .T.	
EndIf	

Begin Transaction

If lResolvQry 
	
	//-- Condicao da query - foi separado pois sera usado na query da exclusao
	cQryCond := "   AMJ_FILIAL = '" + xFilial("AMJ")  + "' AND "
	If !lXML
		cQryCond += "   AMJ_PROCES = '" + AKB->AKB_PROCES + "' AND "
		cQryCond += "   AMJ_ITEM   = '" + AKB->AKB_ITEM   + "' AND "
	Else
		cQryCond += "   AMJ_PROCES = '" + Space(Len(AKB->AKB_PROCES)) + "' AND "
		cQryCond += "   AMJ_ITEM   = '" + Space(Len(AKB->AKB_ITEM))   + "' AND "
	EndIf
	cQryCond += "   ( "
	cQryCond += "		AMJ_DATA = ' ' OR ( AMJ_DATA BETWEEN '" + DtoS( dDatIni ) + "' AND '" + DtoS( dDatFim ) + "' )" 
	cQryCond += "   ) AND "
	cQryCond += "   D_E_L_E_T_ = ' ' "

	//-- Adiciona expressao de filtro convertida para SQL	
	If !Empty(cFiltQry)
		cQryCond += " AND (" + cFiltQry +")"
	EndIf

	nMin		:=	0
	nMax		:= 0
	cQuery	:=	" SELECT Min(R_E_C_N_O_) MinRecno, "
	cQuery	+=	" Max(R_E_C_N_O_) MaxRecno "
	cQuery	+=	" FROM " + RetSqlName("AMJ")
	cQuery	+=	" WHERE "
	cQuery	+=	cQryCond
	cQuery	:=	ChangeQuery(cQuery)
	
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery),"QRYTRB", .F., .F. )
	
	If !Eof()                                           
		nMin	:=	MINRECNO
		nMax	:=	MAXRECNO
	Endif	                                                                             
	
	QRYTRB->( dbCloseArea() )
	
	ProcRegua(Round((nMax-nMin)/10000,0))	
	
	For nX := nMin To nMax	STEP 10000
	
		If __lFKInUse
			cQryFim := " UPDATE " + RetSqlName('AMJ') + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
		Else
			cQryFim	:= " DELETE FROM  "+RetSqlName('AMJ') 
		EndIf
		
		cQryFim += " WHERE "
		cQryFim += cQryCond
		cQryFim += " AND R_E_C_N_O_ BETWEEN "+Str(nX)+ ' AND '+Str(nX+10000)
		
		IncProc(STR0026) //"Apagando Movimentos ..."
		
		If TcSqlExec(cQryFim) <> 0
		
			UserException(	STR0027 + CRLF +  ; //"Erro na exclusao de movimentos "
							STR0028 + CRLF + TCSqlError() ) // "Processo cancelado..."
			lRet	:=	.F.
			Exit 
		
		Else
		
			//Forcar o Commit para DB2 para nao estourar o LOG (mesmo sem ter iniciado transacao)
	   		If Upper(TcGetDb()) == 'DB2'
				TcSqlExec('commit')
  			Endif
   			
		Endif
		
	Next

	TcRefresh(RetSqlName("AMJ"))

	dbSelectArea( "AMJ" )
	
Else

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Conta linhas que serao processadas para montar gauge ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cQuery := "SELECT COUNT(R_E_C_N_O_) TOTREG "
	cQuery += "FROM " + RetSQLName("AMJ") + " AMJ "
	cQuery += "WHERE "
	cQuery += "   AMJ_FILIAL = '" + xFilial("AMJ")  + "' AND "
	If !lXML
		cQuery += "   AMJ_PROCES = '" + AKB->AKB_PROCES + "' AND "
		cQuery += "   AMJ_ITEM   = '" + AKB->AKB_ITEM   + "' AND "
	Else
		cQuery += "   AMJ_PROCES = '" + Space(Len(AKB->AKB_PROCES)) + "' AND "
		cQuery += "   AMJ_ITEM   = '" + Space(Len(AKB->AKB_ITEM))   + "' AND "
	EndIf	
	cQuery += "   D_E_L_E_T_ = ' ' "
	
	cQuery	:=	ChangeQuery(cQuery)
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery),"QRYTRB", .F., .F. )
	
	ProcRegua(QRYTRB->TOTREG)
	
	QRYTRB->( dbCloseArea() )
	dbSelectArea("AMJ")

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Seleciona os lan็amentos do processo para exclusใo ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cQuery := "SELECT R_E_C_N_O_ NUMREC "
	cQuery += "FROM " + RetSQLName("AMJ") + " AMJ "
	cQuery += "WHERE "
	cQuery += "   AMJ_FILIAL = '" + xFilial("AMJ")  + "' AND "
	If !lXML
		cQuery += "   AMJ_PROCES = '" + AKB->AKB_PROCES + "' AND "
		cQuery += "   AMJ_ITEM   = '" + AKB->AKB_ITEM   + "' AND "
	Else
		cQuery += "   AMJ_PROCES = '" + Space(Len(AKB->AKB_PROCES)) + "' AND "
		cQuery += "   AMJ_ITEM   = '" + Space(Len(AKB->AKB_ITEM))   + "' AND "
	EndIf
	cQuery += "   ( "
	cQuery += "		AMJ_DATA = ' ' OR ( AMJ_DATA BETWEEN '" + DtoS( dPeriodoDe ) + "' AND '" + DtoS( dPeriodoAte ) + "' )" 
	cQuery += "   ) AND "
	cQuery += "   D_E_L_E_T_ = ' ' "


	cQuery	:=	ChangeQuery(cQuery)
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery),"QRYAMJ", .F., .F. )

	Do While QRYAMJ->( !Eof() )

		IncProc()

		AMJ->( dbGoTo( QRYAMJ->NUMREC ) )	
		
		If !Empty(cFiltAMJ) .And. !lResolvQry .And. !AMJ->(&cFiltAMJ)
			QRYAMJ->(dbSkip())
			Loop
		EndIf	
		
		RecLock("AMJ",.F.,.T.)
		AMJ->(dbDelete())
		AMJ->(MsUnlock())

		QRYAMJ->(dbSkip())

	EndDo

	QRYAMJ->( dbCloseArea() )
	dbSelectArea( "AMJ" )	

EndIf

End Transaction

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณProcLanc  บAutor  ณMicrosiga           บ Data ณ  08/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCOA009                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ProcLanc(aRet)
Local	nIndex
Local	cIndex   	:= ""
Local cFiltro		:=	""
Local	lCloseArea	:=	.F.
Local bWhile
Local cAlias
Local cProcesso,cItem,cAliasEntid
Local aArea			:= GetArea()
Local aCposForm		:= {}
Local nFor			:= 0
Local nPosCpo		:= 0
Local cContCpo		:= ""   

Local nI := 0

cProcesso 	:= AKB->AKB_PROCES
cItem 		:= AKB->AKB_ITEM
cAliasEntid := GetEntFilt(cProcesso,cItem)

If Empty(cAliasEntid)
	Help("   ",1,"PCONOTABSX2",,STR0051,1,0) // "A tabela informada no campo AKB_ENTIDA nใo existe no dicionแrio de dados, verifique o cadastro em Atualiza็๕es > Lan็amentos > Pontos Lanc Integr."
	Return .F.
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ  Valida os tipos dos dados ou campos informados ณ
//ณ  nos pontos de lancamentos de integracao AMK    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aCposForm	:= 	{	{ "AMK_CO"		,Nil, TamSX3("AMJ_CO")    [3]	},;
					{ "AMK_DATA"	,Nil, TamSX3("AMJ_DATA")  [3]	},;
					{ "AMK_DATPLA"	,Nil, TamSX3("AMJ_DATPLA")[3]	},;
					{ "AMK_CLASSE"	,Nil, TamSX3("AMJ_CLASSE")[3]	},;
					{ "AMK_OPER"	,Nil, TamSX3("AMJ_OPER")  [3]	},;
					{ "AMK_CC"		,Nil, TamSX3("AMJ_CC")    [3]	},;
					{ "AMK_ITCTB"	,Nil, TamSX3("AMJ_ITCTB") [3]	},;
					{ "AMK_CLVLR"	,Nil, TamSX3("AMJ_CLVLR") [3]	},;
					{ "AMK_TIPO"	,Nil, TamSX3("AMJ_TIPO")  [3]	},;
					{ "AMK_VALOR1"	,Nil, TamSX3("AMJ_VALOR1")[3]	},;
					{ "AMK_VALOR2"	,Nil, TamSX3("AMJ_VALOR2")[3]	},;
					{ "AMK_VALOR3"	,Nil, TamSX3("AMJ_VALOR3")[3]	},;
					{ "AMK_VALOR4"	,Nil, TamSX3("AMJ_VALOR4")[3]	},;
					{ "AMK_VALOR5"	,Nil, TamSX3("AMJ_VALOR5")[3]	} } 

aAdd(aCposForm, { "AMK_UNIORC",Nil, TamSX3("AMJ_UNIORC")[3]	})

If nQtdEntid == NIL
	If cPaisLoc == "RUS"
		nQtdEntid := PCOQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
	Else
		nQtdEntid := CtbQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
	EndIf
EndIf

For nI := 5 to nQtdEntid
	aAdd(aCposForm, { "AMK_ENT" + StrZero(nI,2,0),Nil, TamSX3("AMJ_ENT" + StrZero(nI,2,0))[3] })
Next nI

// Macro executo o conteudo do campo e guardo na posicao 2
For nFor := 1 To Len(aCposForm)
	nPosCpo := AMK->(FieldPos(aCposForm[nFor,1]))
	If nPosCpo > 0
		cContCpo := AMK->(FieldGet(nPosCpo))
		If !Empty(cContCpo)
			aCposForm[nFor,2] := Eval( &( "{|| " + cContCpo+" }")) 
		EndIf
	EndIf
Next 

// comparo o Valtype do conteudo macro-executado com o tipo do campo no X3
AMK->(DbSetOrder(1))
AMK->(DbSeek( xFilial("AMK")+cProcesso+cItem ))
While AMK->( !Eof() .And. AMK_FILIAL+AMK_PROCES+AMK_ITEM == xFilial("AMK")+cProcesso+cItem )
	If AMK->AMK_ATIVO == "LBOK"
		For nFor:=1 To Len(aCposForm)
			If !Empty(aCposForm[nFor,2])
				If ValType(aCposForm[nFor,2]) <> aCposForm[nFor,3]
					RestArea(aArea)
					Return .F.
				EndIf
			EndIf
		Next nFor
	EndIf
	AMK->(DbSkip())
End

RestArea(aArea)

PcoIniInt(AKB->AKB_PROCES)

Begin Transaction
	dbSelectArea(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))
	dbSetOrder(1)  
	ProcRegua(RecCount())             
	If !Empty(cFiltro009)
		cFiltro	:=	PcoParseFil(cFiltro009,GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))	
		If !Empty(cFiltro)
			cQuery 	:= " SELECT R_E_C_N_O_ RECTAB "
			cQuery 	+= "  FROM " + RetSQLName(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM)) + " " +GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM)
			cQuery 	+= "  WHERE (" + cFiltro+") AND "// Adiciona expressao de filtro convertida para SQL
			cQuery 	+= " D_E_L_E_T_ <> '*' "
			cQuery 	+= " ORDER BY  " + SqlOrder((GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))->(IndexKey()))			
			cQuery 	:= ChangeQuery(cQuery)
			
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "PCOTRB", .T., .T. )
			DbSelectArea("PCOTRB")
			lCloseArea	:=	.T.
		Else
			cIndex := CriaTrab(,.F.)
			IndRegua(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM),cIndex,IndexKey(),,cFiltro009)
			nIndex := RetIndex(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))
			dbSelectArea(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))
			dbSetOrder(nIndex+1)
		Endif
		DbGoTop()
		bWhile := { || ! Eof() }
	Else
	
		dbSeek(xFilial())
		cAlias := Alias()
		
		If  SubStr( cAlias, 1, 1) == "S" 
			//se a primeira letra do alias for "S" entao	
			//considera campo filial a partir da segunda exemplo tabela SA1 - campo A1_FILIAL
			bWhile := {|| !Eof() .And. &(SubStr( cAlias, 2, 2 ) + "_FILIAL") == xFilial() }
		Else			
			bWhile := {|| !Eof() .And. &(cAlias + "_FILIAL") == xFilial() }
		EndIf
		
	Endif
	
	While Eval(bWhile)
		dbSelectArea(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))
		If lCloseArea
			(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))->(MsGoTo(PCOTRB->RECTAB))
		Endif	
		IncProc()
		If A009FilInt(AKB->AKB_PROCES,AKB->AKB_ITEM,aRet)
			
			If !DetProc(AKB->AKB_PROCES,AKB->AKB_ITEM)    //processos normais

				PcoDetInt(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA009")

			Else
                //processos de rateio que utilizam outra tabela alem da de origem
			    If  (AKB->AKB_PROCES == "000002" .And. (AKB->AKB_ENTIDA == "SEZ" .OR.AKB->AKB_ENTIDA == "SEV") .OR. ;
					AKB->AKB_PROCES == "000001" .And. (AKB->AKB_ENTIDA == "SEZ" .OR.AKB->AKB_ENTIDA == "SEV") )			    

					aDetProc	:=	GetDetProc(AKB->AKB_PROCES,AKB->AKB_ITEM)
					DbSelectArea(aDetProc[1,1])
					DbSetOrder(aDetProc[1,2])
					DbSeek(Eval(aDetProc[1,3]))
					While !Eof() .And. Eval(aDetProc[1,4])
						//SEV
						If Len(aDetProc)==1
							PcoDetInt(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA009")
							DbSelectArea(aDetProc[1,1])
							DbSkip()
						Else
						//SEZ
							DbSelectArea(aDetProc[2,1])
							DbSetOrder(aDetProc[2,2])
							DbSeek(Eval(aDetProc[2,3]))
							While !Eof() .And. Eval(aDetProc[2,4])
								PcoDetInt(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA009")
								DbSelectArea(aDetProc[2,1])
								DbSkip()
							Enddo
							DbSelectArea(aDetProc[1,1])
							DbSkip()
						Endif
					Enddo					
					dbSelectArea(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))

			    ElseIf AKB->AKB_PROCES == "000054" 
			    			    
			    	If	AKB->AKB_ITEM $ '09|10|11' .And. AKB->AKB_ENTIDA == "SDE"
						aDetProc :=	GetDetProc(AKB->AKB_PROCES,AKB->AKB_ITEM)
						DbSelectArea(aDetProc[1,1])
						DbSetOrder(aDetProc[1,2])
						If DbSeek(Eval(aDetProc[1,3])) 
							Posic_Tabelas( aDetProc[1,5] )
						EndIf	
						Do While !Eof() .And. Eval(aDetProc[1,4])
							PcoDetInt(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA009")
							DbSelectArea(aDetProc[1,1])
							DbSkip()
						EndDo
						dbSelectArea(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))
					ElseIf AKB->AKB_ITEM $ '01|05' .And. AKB->AKB_ENTIDA == "SD1"	
						aDetProc :=	GetDetProc(AKB->AKB_PROCES,AKB->AKB_ITEM)
						DbSelectArea(aDetProc[1,1])
						DbSetOrder(aDetProc[1,2])
						DbSeek(Eval(aDetProc[1,3])) 
  						If Eval(aDetProc[1,6])
							PcoDetInt(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA009")
						EndIf
						DbSelectArea(aDetProc[1,1])
						dbSelectArea(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))
					EndIf
					
				// Processos de movimentacao internas, producao e acerto de inventario devem gerar os 
				// lancamentos na tabela AMJ de acordo com o campo D3_TM da tabela SD3.
				ElseIf AKB->AKB_PROCES $ "000151|000152|000153" .And.;
						AKB->AKB_ITEM $ "01|02" .And.;
						AKB->AKB_ENTIDA == "SD3"

					// Movimentos internos
					If AKB->AKB_PROCES == "000151"
						If AKB->AKB_ITEM == "01" .And. SD3->D3_TM <= "500"
							PcoDetInt(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA009")
						ElseIf AKB->AKB_ITEM == "02" .And. SD3->D3_TM > "500"
							PcoDetInt(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA009")
						EndIf             
					// Producao
					ElseIf AKB->AKB_PROCES == "000152" .And. SubStr(SD3->D3_CF,1,2) $ "PR|ER"
						If AKB->AKB_ITEM == "01" .And. SD3->D3_TM <= "500"
							PcoDetInt(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA009")
						ElseIf AKB->AKB_ITEM == "02" .And. SD3->D3_TM > "500"
							PcoDetInt(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA009")
						EndIf                                            
					// Inventario
					ElseIf AKB->AKB_PROCES == "000153" .And. SD3->D3_DOC == "INVENT"
						If AKB->AKB_ITEM == "01" .And. SD3->D3_TM <= "500"
							PcoDetInt(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA009")
						ElseIf AKB->AKB_ITEM == "02" .And. SD3->D3_TM > "500"
							PcoDetInt(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA009")
						EndIf
					EndIf	
				ElseIf AKB->AKB_PROCES == "000358" .And. AKB->AKB_ITEM == '01' // Rotina de planejamento orcamentario
					DbSelectArea("ALX")
					DbSetOrder(2)
					If DbSeek(xFilial("ALX")+ALY->ALY_PLANEJ+ALY->ALY_VERSAO+ALY->ALY_SEQ) // Posiciona Tabela ALX
					
						PcoDetInt(AKB->AKB_PROCES,AKB->AKB_ITEM,"PCOA009")
					
					EndIf
				EndIf            

			Endif			
		EndIf
		
		If lCloseArea
			dbSelectArea("PCOTRB")
		Else
			dbSelectArea(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))
		Endif
		dbSkip()
	EndDo                        
	If lCloseArea
		DbSelectArea("PCOTRB")
		DbCloseArea()
		DbSelectArea(GetEntFilt(AKB->AKB_PROCES,AKB->AKB_ITEM))
	Endif		
End Transaction		      

PcoFinInt(AKB->AKB_PROCES)

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetEntFiltบAutor  ณMicrosiga           บ Data ณ  08/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCOA009                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GetEntFilt(cProcesso,cItem)
Local aArea		:= GetArea()
Local aAreaAKB	:= AKB->(GetArea())
Local cRet		:= ""

DbSelectArea('AKB')
DbSetOrder(1)
If MsSeek(xFilial()+cProcesso+cItem)
	cRet	:=	AKB->AKB_ENTIDA

	If AliasInDic(cRet)

		If cProcesso == "000002" .And. (AKB->AKB_ENTIDA == "SEZ" .OR.AKB->AKB_ENTIDA == "SEV")
			cRet	:=	"SE2"                                                                       
		ElseIf cProcesso == "000001" .And. (AKB->AKB_ENTIDA == "SEZ" .OR.AKB->AKB_ENTIDA == "SEV")
			cRet	:=	"SE1"       
		ElseIf cProcesso == "000054" .And. AKB->AKB_ENTIDA == "SDE"
			cRet	:=	"SD1"       
		EndIf
		
		DbSelectArea(cRet)
	
	Else
		cRet := ""
	EndIf
	
EndIf

RestArea(aAreaAKB)
RestArea(aArea)

Return cRet              

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDetProc   บAutor  ณMicrosiga           บ Data ณ  08/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCOA009                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DetProc(cProcesso, cItem)

Local lRet	:=	.F.
If cProcesso == "000002" .And. (cItem == '04' .OR. cItem == '05')
	lRet	:=	.T.
ElseIf cProcesso == "000001" .And. (cItem == '04' .OR. cItem == '05')
	lRet	:=	.T.
ElseIf cProcesso == "000054" .And. cItem $ '09|10|11'
	lRet	:=	.T.
ElseIf cProcesso == "000054" .And. cItem $ '01|05'
	lRet	:=	.T.
ElseIf cProcesso $ "000151|000152|000153" .And. cItem $ '01|02'
	lRet	:=	.T.
ElseIf cProcesso $ "000358" .And. cItem $ '01' // Rotina de planejamento orcamentario
	lRet	:=	.T.
Endif	                                                                	
Return lRet              

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetDetProcบAutor  ณMicrosiga           บ Data ณ  08/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCOA009                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GetDetProc(cProcesso, cItem)

Local lRet		:=	.F.
Local aDetProc	:=	{}
Local cChaveSEV	:= ""
Local cChaveSDE	:= ""
Local cChaveSD1	:= ""
         
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณEstrutura do Array aDetProc                                                                ณ
//ณ                                                                                           ณ
//ณaDetProc[n,1] - Alias da tabela principal do lancamento na AMJ                             ณ
//ณaDetProc[n,2] - Indice para posicionamento (dbSetOrder)                                    ณ
//ณaDetProc[n,3] - Chave do registro posicionado para pesquisa na tabela principal            ณ
//ณaDetProc[n,4] - Chave para condicao do loop                                                ณ
//ณaDetProc[n,5] - Tabelas para posicionar a partir da tabela principal (funcao Posic_Tabelas)ณ
//ณaDetProc[n,5,1] - Alias da tabela secundaria                                               ณ
//ณaDetProc[n,5,2] - Ordem para pesquisa                                                      ณ
//ณaDetProc[n,5,3] - Chave para pesquisa                                                      ณ
//ณaDetProc[n,6] - Condicao de filtro para nao processar linha da tabela principal            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If cProcesso == "000002"  .And. (cItem == '04' .Or. cItem == '05')
	aDetProc	:=	Array(1,4)
	aDetProc[1,1]	:=	"SEV"
	aDetProc[1,2]	:=	2                
	cChaveSeV := RetChaveSev("SE2")
	aDetProc[1,3]	:=	&('{|| "' + cChaveSEV + '"}')
	aDetProc[1,4]	:=	&('{|| xFilial("SEV")+SEV->(EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIFOR+EV_LOJA+EV_IDENT) == "' + cChaveSEV +"1"+'"}')
	If cItem == '05'
		AAdd(aDetProc,Array(4))
		aDetProc[2,1]	:=	"SEZ"
		aDetProc[2,2]	:=	4
		cChaveSeV := RetChaveSev("SE2",,"SEZ")
		aDetProc[2,3]	:=	&('{|| "' + cChaveSEV + '"+ SEV->EV_NATUREZ }')
		aDetProc[2,4]	:=	&('{|| xFilial("SEZ")+SEZ->(EZ_PREFIXO+EZ_NUM+EZ_PARCELA+EZ_TIPO+EZ_CLIFOR+EZ_LOJA+EZ_NATUREZ+EZ_IDENT) == "' + cChaveSEV +'"+SEV->EV_NATUREZ+"1"}')
	Endif
ElseIf cProcesso == "000001" .And. (cItem == '04' .OR. cItem == '05')
	aDetProc	:=	Array(1,4)
	aDetProc[1,1]	:=	"SEV"
	aDetProc[1,2]	:=	2                
	cChaveSeV := RetChaveSev("SE1")
	aDetProc[1,3]	:=	&('{|| "' + cChaveSEV + '"}')
	aDetProc[1,4]	:=	&('{|| xFilial("SEV")+SEV->(EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIFOR+EV_LOJA+EV_IDENT) == "' + cChaveSEV +"1"+'"}')
	If cItem == '05'      
		AAdd(aDetProc,Array(4))
		aDetProc[2,1]	:=	"SEZ"
		aDetProc[2,2]	:=	4
		cChaveSeV := RetChaveSev("SE1",,"SEZ")
		aDetProc[2,3]	:=	&('{|| "' + cChaveSEV + '"+ SEV->EV_NATUREZ }')
		aDetProc[2,4]	:=	&('{|| xFilial("SEZ")+SEZ->(EZ_PREFIXO+EZ_NUM+EZ_PARCELA+EZ_TIPO+EZ_CLIFOR+EZ_LOJA+EZ_NATUREZ+EZ_IDENT) == "' + cChaveSEV +'"+SEV->EV_NATUREZ+"1"}')
	Endif
ElseIf cProcesso == "000054" .And. cItem $ '09|10|11'
	aDetProc	:=	Array(1,5)
	aDetProc[1,1]	:=	"SDE"
	aDetProc[1,2]	:=	1
	cChaveSDE 		:=  RetChaveSDE("SD1")
	aDetProc[1,3]	:=	&('{|| "' + cChaveSDE  + '"}')
	aDetProc[1,4]	:=	&('{|| xFilial("SDE")+SDE->(DE_DOC+DE_SERIE+DE_FORNECE+DE_LOJA+DE_ITEMNF) == "' + cChaveSDE +'" }')
	aDetProc[1,5]	:=	{}   //ARRAY PARA POSICIONAR TABELAS CONFORME ITEM 	
	aAdd(aDetProc[1,5], { "SF1", 1, &('{|| "' + RetChaveSDE("SD1",,"SF1") + '"}') })
	aAdd(aDetProc[1,5], { "SB1", 1, &('{|| xFilial("SB1")+'+GetEntFilt(cProcesso,cItem)+'->D1_COD }') })
	aAdd(aDetProc[1,5], { "SA2", 1, &('{||  xFilial("SA2")+'+GetEntFilt(cProcesso,cItem)+'->(D1_FORNECE+D1_LOJA) }') })
ElseIf cProcesso == "000054" .And. cItem $ '01|05'
	aDetProc	:=	Array(1,6)
	aDetProc[1,1]	:=	"SD1"
	aDetProc[1,2]	:=	1                   
	cChaveSD1		:=	SD1->(IndexKey(1))
	aDetProc[1,3]	:=	&("{|| "+cChaveSD1+"}")
	aDetProc[1,4]	:=	{}
	aDetProc[1,5]	:=	{}   
	If cItem == "01"
		aDetProc[1,6] := {|| SD1->D1_TIPO <> "D"}
	Else	
		aDetProc[1,6] := {|| SD1->D1_TIPO == "D"}
	EndIf	
Endif	                                                                	

Return aDetProc

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRetChaveSDEบAutor  ณMicrosiga          บ Data ณ  08/12/10   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCOA009                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RetChaveSDE(cAlias,cCampo,cArqKey)
Local cChave

cArqKey := IIf(cArqKey == NIL,"SDE",cArqKey)

If cAlias $ "SD1|SF1"
	cCampo := Right(cAlias,2)
Endif
cChave := xFilial(cArqKey)+(cAlias)->&(cCampo+"_DOC")+(cAlias)->&(cCampo+"_SERIE")+;
		  					    (cAlias)->&(cCampo+"_FORNECE")+(cAlias)->&(cCampo+"_LOJA")+;
								If(cArqKey=='SF1', "", (cAlias)->&(cCampo+"_ITEM"))		  					    
Return cChave


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPosic_TabelasบAutor  ณMicrosiga        บ Data ณ  08/12/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCOA009                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Posic_Tabelas(aPosic)
Local nX
Local aArea := GetArea()
Local nOrdem := 0
Local nPosAlias

nPosAlias := ASCAN(aPosic, {|aVal| aVal[1] == aArea[1] })

For nX := 1 TO Len(aPosic)
	dbSelectArea(aPosic[nX,1])
	nOrdem := IndexOrd()
	dbSetOrder(aPosic[nX,2])
	dbSeek(Eval(aPosic[nX,3]))
	//depois que posicionou retorna para dbsetorder() de origem
	//atencao -> nao pode ser utilizado Getarea() / RestArea() - deve ficar posicionado
	dbSetOrder(nOrdem)
Next

If nPosAlias > 0   //se tiver que posicionar na tabela atual soh retorna para alias
	dbSelectArea(aArea[1])
Else  //senao restaura a area
	RestArea(aArea)
EndIf	

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณMenuDef   ณ Autor ณ Daniel Leme           ณ Data ณ29/07/10  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Utilizacao de menu Funcional                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณArray com opcoes da rotina.                                 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function MenuDef()
Local aRotina 	:= {	{ STR0002	, "AxPesqui"		, 0, 1},;	//-- "Pesquisar"
						{ STR0003	, "PCOA009DLG" 		, 0, 2},; 	//-- "Reprocessar"
						{ STR0029	, "ProcLogView()"	, 0, 2},;	//-- "Visualizar Log"
						{ STR0030	, "PCOA009XML" 		, 0, 3}} 	//-- "Importar XML"
Return(aRotina)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA009   บAutor  ณMicrosiga           บ Data ณ  02/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImporta o arquivo XML e prepara para gravacao dos dados     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOA009Xml()
Local aParametros := {}
Local aRet			:= {}
Local cDirDstXML	:= Upper(SuperGetMv("MV_LOCPCO",,"\INTEGRAPCO\"))
Local aRetFil		:= {}
Local cFiltAMJ		:= ""
Local lRet			:= .T.
Local cNomeXml		:= ""
Local cExtensao		:= ""
Local cDrive		:= ""
Local cDiretorio	:= ""
Local aRet009XML	:= {}
Local aOpcArqXml	:= {}
Local lMVXmlOP		:= Iif(AllTrim(SuperGetMV("MV_PCOXMOP",,"1")) == "1" , .T. , .F. )
Local lMVXmlCC		:= Iif(AllTrim(SuperGetMV("MV_PCOXMCC",,"1")) == "1" , .T. , .F. )
Local lMVXmlIT		:= Iif(AllTrim(SuperGetMV("MV_PCOXMIT",,"1")) == "1" , .T. , .F. )
Local lMVXmlCV		:= Iif(AllTrim(SuperGetMV("MV_PCOXMCV",,"1")) == "1" , .T. , .F. ) 

Local lMVXmlUO 	:= .T.
Local aMVXmlEnt   := {.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.}
Local nI := 0    

If SuperGetMV("MV_PCOINTE",.T.,"2")!="1"
	Help("   ",1,"PCOMVPCOINTE",,cMsgHelp,1,0)
	Return
EndIf

aParametros := { 	{ 5, STR0004,.F.,120,,.F.},; //1 "Apagar lan็amantos do periodo ?"					
					{ 5, STR0052,lMVXmlOP,100,,.F.},; //2 "Arquivo cont้m Opera็ใo?"
					{ 5, STR0053,lMVXmlCC,100,,.F.},; //3 "Arquivo cont้m Centro Custo?"
					{ 5, STR0054,lMVXmlIT,100,,.F.},; //4 "Arquivo cont้m Item Contแbil?"
					{ 5, STR0055,lMVXmlCV,100,,.F.},; //5 "Arquivo cont้m Classe Valor?"
					{ 5, STR0057,lMVXmlUO,100,,.F.},; //6 "Arquivo cont้m Unid. Or็amentแria?"
					{ 1, STR0005,CTOD("  /  /  "),"" 	 ,""  ,""    ,"" ,50 ,.T. },; //7 "Periodo de"
					{ 1, STR0006,CTOD("  /  /  "),"" 	 ,"MV_PAR08>MV_PAR07"  ,""    ,"" ,50 ,.T. },; //8 "Periodo Ate"
					{ 6, STR0045,Space(120),"@!","File(MV_PAR09)","",85,.T.,STR0046,"",GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE}} //9 "Selecione o Arquivo" ## "Arquivos .XML | *.XML"

If nQtdEntid == NIL //alteracao
	If cPaisLoc == "RUS"
		nQtdEntid := PCOQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
	Else
		nQtdEntid := CtbQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
	EndIf
EndIf

CT0->(dbSetOrder(1)) //alteracao

For nI := 5 to nQtdEntid //alteracao
	CT0->(dbSeek(xFilial("CT0")+StrZero(nI,2,0)))
	aAdd(aParametros, { 5, STR0058 + AllTrim(CT0->CT0_DSCRES) + "?", aMVXmlEnt[nI-4],100,,.F.}) //"Arquivo cont้m "
Next nI

If (lRet := ParamBox(aParametros,STR0009,aRet)) //"Parametros"
	lDelPeriodo			:= aRet[1]
	Aadd(aOpcArqXml,       aRet[2]) // Arquivo cont้m Opera็ใo?
	Aadd(aOpcArqXml,       aRet[3]) // Arquivo cont้m Centro Custo?
	Aadd(aOpcArqXml,       aRet[4]) // Arquivo cont้m Item Contแbil?
	Aadd(aOpcArqXml,       aRet[5]) // Arquivo cont้m Classe de Valor?
	Aadd(aOpcArqXml,       aRet[6]) // Arquivo cont้m Unidade Or็amentแria?
	For nI := 5 to nQtdEntid //alteracao
   		Aadd(aOpcArqXml,   aRet[nI+5]) // Arquivo cont้m Entidades
	Next nI
	
	cFilialDe			:= cFilAnt
	cFilialAte			:= cFilAnt
	dPeriodoDe			:= aRet[7] // aRet[2]
	dPeriodoAte			:= aRet[8] // aRet[3]
	cArqOriXML			:= AllTrim(aRet[9])	 // aRet[4]
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ  Se o diretorio nao existir, pega o RootPath  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !ExistDir(cDirDstXML)
		MakeDir(cDirDstXML)
	EndIf

	// Separa cada item de um arquivo: SplitPath ( < cArquivo>, [ @cDrive], [ @cDiretorio], [ @cNome], [ @cExtensao] ) --> Nil
	SplitPath( cArqOriXML, @cDrive, @cDiretorio, @cNomeXml , @cExtensao )
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ  Verifica se o arquivo esta no servidor ou nao        ณ
	//ณ  Se Empty(cDrive) esta no servidor, senao esta local  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If Empty(cDrive)
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ  Esta no servidor, mas nao esta no diretorio \INTEGRAPCO\  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If UPPER(cDiretorio) != UPPER(cDirDstXML)
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ	
			//ณ Copio o arquivo do de algum diretorio do server para o diretorio de integracao ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If !__CopyFile( cDiretorio+cNomeXml+cExtensao , cDirDstXML+cNomeXml+cExtensao )
				Help("   ",1,"PCONOCPYXML",,STR0031+cDirDstXML+CRLF+STR0047,1,0) //"Nใo foi possํvel copiar o arquivo XML para o Servidor Protheus na pasta " ## "Verificar as permiss๕es de leitura ou escrita das pastas."
				lRet := .F.
			EndIf
			
			cArqOriXML := cDirDstXML + cNomeXml + cExtensao
	
		EndIf
	
	Else
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ  Utilizada a funcao CpyT2S() pois o parse do objeto oXML so funciona no rootpath  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If !CpyT2S( cArqOriXML, cDirDstXML )
			Help("   ",1,"PCONOCPYXML",,STR0031+cDirDstXML+CRLF+STR0047,1,0) //"Nใo foi possํvel copiar o arquivo XML para o Servidor Protheus na pasta " ## "Verificar as permiss๕es de leitura ou escrita das pastas."
			lRet := .F.
		EndIf
		
		cArqOriXML := cDirDstXML + cNomeXml + cExtensao	
		
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Inicia o log de processamento  - nao tirar a linha abaixo  ณ
	//ณ pois funcao ProcLogIni utiliza as variaveis mv_par private ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	AEval( aRet, { |x,y| SetPrvt("MV_PAR"+AllTrim(STRZERO(y,2,0))), &("MV_PAR"+AllTrim(STRZERO(y,2,0))) := x } )

	If lDelPeriodo

		If Aviso(STR0010,STR0032,{STR0017,STR0018})==1  //"Atencao"##"Filtrar os lancamentos XML existentes para exclusao do periodo selecionado ?"##"Sim"##"Nao"

			If (lRet := ParamBox( { { 7 , STR0007+STR0019,"AMJ",""} }, STR0009, aRetFil,,,,,,, "PCOA009_1", .F., .F.)) //"Parametros"##"[ Excluir os Movimentos - AMJ ]"
				If !Empty(aRetFil[1])
					cFiltAMJ := aRetFil[1]
					lRet := .T.
				Else
					lRet := .F.
				EndIf
			EndIf

			If !lRet
				Aviso(STR0010, STR0020, {"Ok"})  //"Atencao"##"Filtro nao informado. Operacao Cancelada!"
			EndIf	
			
			AEval( aRet, { |x,y| SetPrvt("MV_PAR"+AllTrim(STRZERO(y,2,0))), &("MV_PAR"+AllTrim(STRZERO(y,2,0))) := x } )
				
		Else

			If Aviso(STR0010,STR0033,{STR0017, STR0018} ) == 1  //"Atencao"##"Confirma a exclusao de todos os lancamentos XML do periodo selecionado?"##"Sim"##"Nao"
				lRet := .T.
			Else
				lRet := .F.
			EndIf	

		EndIf

	EndIf

	If lRet .And. lDelPeriodo

		Processa({|| ProcDel(aRet, cFiltAMJ, .T.)}, STR0013, STR0014 )	// "Processando lan็amentos" ### "Excluindo lancamentos..."
				
	EndIf
	
	If lRet

		Processa({|| aRet009XML := A009Xml(cArqOriXML,dPeriodoDe,dPeriodoAte,aOpcArqXml)}, STR0013, STR0015 )		// "Processando lan็amentos" ### "Gerando lancamentos..."
	
	EndIf

	If Len(aRet009XML) > 0
		Help("   ",1,"PCONOCPYXML",,STR0041+CRLF+STR0048,1,0)
	EndIf

EndIf

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA009A  บAutor  ณ Daniel Leme        บ Data ณ  07/27/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para preenchimento da area de Integra็ใo do PCO -   บฑฑ
ฑฑบ          ณ tabela AMJ                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCO009                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOA009A(xAutoItens, nOpcAuto )
Private cCadastro	:= STR0044 // "Cadastro de Recursos"
Private aRotina		:= MenuDefA()
Private lPCO9aAuto	:= xAutoItens <> NIL
Private aAutoItens	:= {}

Default xAutoItens  := {}
Default nOpcAuto    := 3
          
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Endereca a funcao de BROWSE                                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !lPCO9aAuto
	//mBrowse(6,1,22,75,"AMJ")
Else
	aAutoItens  := xAutoItens
	
	MBrowseAuto(nOpcAuto,Aclone(aAutoItens),"AMJ")
EndIf

Return Nil

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณPCOA009Mntณ Autor ณ Daniel Leme           ณ Data ณ26/07/2010 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ Manuten็ใo de Integra็ใo do PCO                             ณฑฑ
ฑฑณ          ณ                                                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC1: Alias da tabela                                      ณฑฑ
ฑฑณ          ณ ExpN2: Numero do Registro                                   ณฑฑ
ฑฑณ          ณ ExpN3: Opcao do aRotina                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ PCOA009A                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function A009AMnt(cAlias, nReg, nOpcx)

Local aAreaAtu := GetArea()
Local nOpcA			:= 0
Local nOpcB			:= 0

//-- Dialog
Local oTmsDlgEsp
Local aNoFields		:= {}
Local aYesFields	:= {}
Local aTmp       	:= {}
Local nI         	:= 0

//-- EnchoiceBar
Private aTela[0][0]
Private aGets[0]

//-- GetDados
Private aHeader	 	:= {}
Private aCols	    := {}

//-- Inicializa Parametros da Funcao com Valores Default para Inclusao                     
Default cAlias 	:= "AMJ"
Default nReg	:= 0
Default nOpcx	:= 3 // Inclusao       


nOpcB := aRotina[nOpcx,4]

//-- Configura variaveis da Enchoice
RegToMemory( cAlias, nOpcx == 3 )


//-- Determina campos que nใo aparecem na GETDADOS
aNoFields := {"AMJ_LOTE"}      

//-- Carrega os campos enviados pela ExecAuto na getdados
If Type("aAutoItens") == "A" .And. !Empty(aAutoItens) .And. ValType(aAutoItens[1]) == "A"
	aEval(aAutoItens[1],{|x| Iif( AllTrim(x[1]) != "AMJ_LOTE",;
										aAdd( aYesFields,x[1]),;
										Nil) })
EndIf
//-- Configura variaveis da GetDados          
TMSFillGetDados( nOpcx, 'AMJ', 1, xFilial( 'AMJ' ) + M->AMJ_LOTE, { || AMJ->(AMJ_FILIAL+AMJ_LOTE) },;
																		 { || .T. }, aNoFields,	aYesFields )						 
//-- Valida Altera็ใo/Exclusao
If !INCLUI
	Return nOpcA
EndIf

If lPCO9aAuto
	For nI := 1 To Len(aAutoItens)
		AAdd(aTmp, aAutoItens[nI])
		
		If nI % 100 == 0 .Or. nI == Len(aAutoItens)
		
			If MsGetDAuto(aTmp,"",{|| A009ATOk(nOpcB) },,   nOpcB)
				A009AGrv(nOpcx)
				If __lSX8
					ConfirmSX8()
				EndIf
				nOpca := 1
			EndIf
			
			aTmp := {}
		EndIf	
	Next nI
	
Else
	If nOpcA == 1
		A009AGrv(nOpcx)
		If __lSX8
			ConfirmSX8()
		EndIf
	Else
		If	__lSX8
			RollBackSX8()
		EndIf
	EndIf
EndIf

RestArea(aAreaATU)

Return nOpcA

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ A009AVld  ณ Autor ณ Daniel Leme          ณ Data ณ 26/07/10 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Rotina de validacao                                     	  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ ExpL1 : Validacao Ok (.T.) ou nao (.F.)                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ A009AVld()                                                 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function A009AVld()
Local lRet     := .T.
Local cCampo 	:= ReadVar()
Local aArea		:= GetArea()

If Type("lPCO9aAuto") != "L" 
	Private lPCO9aAuto := .F.
EndIf

Do Case
	Case cCampo == "M->"
EndCase	

RestArea(aArea)

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ A009ALOk บAutor  ณ Daniel Leme        บ Data ณ  26/07/2010 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Linha OK                                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A009ALOk( nOpc )
Local lRet			:= .T.        
Local aArea			:= GetArea()
Local aCpoCheck	:= {}
Local aCpoNoEmp	:= {}  
Local nCtn			:= 0      

//-- Analisa se ha itens duplicados na GetDados.
If !GDDeleted(n) 
	lRet := MaCheckCols(aHeader,aCols,n)
	If lRet .And. !Empty(aCpoCheck)
		lRet := GDCheckKey(aCpoCheck,4)
	EndIf
EndIf

//-- Analisa se ha itens vazios na GetDados.
If !GDDeleted(n) .And. lRet
	For nCtn := 1 To Len(aCpoNoEmp)
		lRet := !Empty(GdFieldGet(aCpoNoEmp[nCtn],n))
		If !lRet
			Help('   ',1,'OBRIGAT',,aHeader[GdFieldPos(aCpoNoEmp[nCtn]),1],1,0)
			Exit
		EndIf
	Next 

EndIf

RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ A009ATOk บAutor  ณDaniel Leme         บ Data ณ  26/07/2010 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tudo OK                                                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A009ATOk( nOpcx )
Local lRet			:= .T.
Local nOld 			:= N
Local nI				:= 0   

If nOpcx <> 2
	For nI := 1 To Len(aCols)
		n := nI
		lRet := A009ALOk( nOpcx )
		If !lRet
			Exit
		EndIf
	Next
EndIf
N := nOld
                       
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ A009AWhe ณ Autor ณ Daniel Leme           ณ Data ณ26/07/2010ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Habilita a digitacao do campo                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ                                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function A009AWhe(cCampo) 

Local   lRet	:= .T.
Default cCampo := ReadVar()

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ A009AGrv ณ Autor ณ Daniel Leme           ณ Data ณ26/07/2010ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Gravacao dos dados                                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ                                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
 Function A009AGrv(nOpcx)

Local aArea		:= GetArea()
Local aAreaAMJ	:= AMJ->(GetArea())
Local nCntFor	:= 0
Local nCntFo1	:= 0    
Local nValNovo	:= 0
Local nValOri	:= 0 
Local lRet		:=.T.

Begin Transaction

	DbSelectArea("AMJ")
	For nCntFor := 1 To Len( aCols )
		If	nOpcx != 5 .And. !GDDeleted( nCntFor ) 
			If !INCLUI 
				RecLock('AMJ',.F.)
			Else
				RecLock('AMJ',.T.)
			EndIf				

			//-- Grava campos da Enchoice (MsMGet)
			aEval( AMJ->(dbStruct()), { |aFieldName, nI | FieldPut( nI, If('FILIAL' $ aFieldName[1],;
																							xFilial( "AMJ" ),;
																							M->&(aFieldName[1]) ) ) } )
			//-- Grava Campos da GetDados
			For nCntFo1 := 1 To Len(aHeader)
				If	aHeader[nCntFo1,10] != 'V' .and. !Upper(aHeader[nCntFo1,1]) =='FILIAL' 
					FieldPut(FieldPos(aHeader[nCntFo1,2]), aCols[nCntFor,nCntFo1])
				Else
					FieldPut(FieldPos(aHeader[nCntFo1,2]),xFilial( "AMJ" ))
				EndIf
			Next              
			MsUnLock()
		Else
			AMJ->(DbSetOrder(1))
			If AMJ->(DbSeek( xFilial('AMJ')+ M->AMJ_LOTE + GDFieldGet('AMJ_ID',nCntFor) ))
				RecLock('AMJ',.F.)
				dbDelete()
				MsUnLock()
			EndIf
		EndIf
	Next nCntFor
	   
End Transaction

RestArea(aAreaAMJ)
RestArea(aArea)

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ MenuDefA  ณ Autor ณ Daniel Leme          ณ Data ณ 26/07/10 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Rotina de Configuracao de Menu P10                      	  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ ExpA1 : Array aRotina                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ PCOA009A                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function MenuDefA()
Local aRotina	:= {	{STR0002, "AxPesqui",0,1},;	 // "Pesquisar"
						{STR0034, "A009AMnt",0,2},;	 // "Visualizar"
						{STR0035, "A009AMnt",0,3},;	 // "Incluir"
						{STR0036, "A009AMnt",0,4},;	 // "Alterar"
						{STR0037, "A009AMnt",0,5}}  // "Excluir"

     
Return(aRotina)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ A009Xml  บAutor  ณ Daniel Leme        บ Data ณ  07/27/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que efetua leitura e valida็๕es do XML, enviando-o  บฑฑ
ฑฑบ          ณ para grava็ใo da แrea de Integra็ใo do PCO - Tabela AMJ    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCOA009B                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A009Xml(cArqOriXML,dDtIni,dDtFim,aOpcArqXml)
Local cAviso 		:= ""
Local cErro			:= ""
Local lContinua 	:= .F.
Local aProcessos 	:= {}
Local aErros	 	:= {}
Local aErroAuto 	:= {}
Local oXml 		:= tXMLManager():New()  //Instanciar
Local nI,aCab,aItens
Local cPathXMLOK	:= SuperGetMv("MV_LOCOPCO",,"\INTEGRAPCO\LIDOSOK\")
Local cPathXMLErr	:= SuperGetMv("MV_LOCEPCO",,"\INTEGRAPCO\LIDOSERRO\")
Local cArqDest		:= ""
Local cTxtErro		:= ""
Local nX			:= 0
Local oFont			:= Nil
Local oDlg			:= Nil
Local nProcesso := 0
Local nItem := 0
Local aRegs := {}
Local aProc := {} 

Private lMsErroAuto := .F.
Private lMsHelpAuto	:= .T.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ  Verifica se existem os diretorios, senao existir, cria  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !ExistDir(cPathXMLOK)
	MakeDir(cPathXMLOK)
EndIf
If !ExistDir(cPathXMLErr)
	MakeDir(cPathXMLErr)
EndIf

//-- Realiza leitura do XML, validando a estrutura, e retornando-o como objeto
oXml:ParseFile( cArqOriXML ) //Carrega a estrutura do arquivo xml

cArqDest := Substr(cArqOriXML,Rat("\",cArqOriXML)) 

//-- Caso nใo exista erro de estrutura do XML, processa-o, transformando-o em array para ExecAuto
If Empty(cAviso) .And. Empty(cErro) .And. ValType(oXML) == "O" 

	If (lContinua := A009OtoA(oXML,@aProcessos,dDtIni,dDtFim,@aErros,aOpcArqXml))
		ProcRegua(Len(aProcessos))
		For nI:= 1 To Len(aProcessos)
			IncProc(STR0015) // "Gerando lan็amentos..."

			aItens		:= aProcessos[nI][2] //-- O ultimo item do array sใo os itens 
			MSExecAuto({|x,y| PCOA009A(x,y)},aItens,3)
			
			If lMsErroAuto
		     	MostraErro()
				If !Empty(cPathXMLErr)
					If __CopyFile(cArqOriXML, cPathXMLErr+cArqDest )
						FErase(cArqOriXML)
					EndIf
				EndIf
			Else
				If !Empty(cPathXMLOK)
					If __CopyFile(cArqOriXML, cPathXMLOK+cArqDest )
						FErase(cArqOriXML)
					EndIf
				EndIf
				MsgInfo(STR0039) // "Arquivo Processado com Sucesso!"
			EndIf                         
		Next nI
	EndIf
Else
	Help("   ",1,"PCOIMPXML",,cAviso,1,0)
EndIf

oXml := Nil
DelClassIntF()

If File(cArqOriXML)
	If FErase(cArqOriXML) < 0
		Help("   ",1,"PCOIMPXML",,STR0040+cArqOriXML,1,0) // "Nใo foi possํvel deletar o arquivo: "
	EndIf
EndIf

Return aErros                   
                          
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA009OtoA  บAutor  ณ Daniel Leme        บ Data ณ  07/27/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que converte as informa็๕es do objeto XML para um   บฑฑ
ฑฑบ          ณ array para ser utilizado na Grava็ใo da แrea de Integra็ใo บฑฑ
ฑฑบ          ณ do PCO - tabela AMJ                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCOA009B                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A009OtoA(oXML,aProcessos,dDtIni,dDtFim,aErros,aOpcArqXml)
	Local lRet		:= .T.
	Local nProcess	:= 0
	Local nItens	:= 0
	Local aItens	:= {}
	Local aItem		:= {}
	Local nI,nJ,bError,uVarAux  
	Local nX := 0
	
	Local nPosIdProc  := 0
	Local nPosDatPla  := 0
	Local nPosDatMov  := 0
	Local nPosValor1  := 0
	Local nPosConta   := 0
	Local nPosClasse  := 0
	Local nPosOper    := 0
	Local nPosCcusto  := 0
	Local nPosItem    := 0
	Local nPosClvlr   := 0
	Local nPosUni     := 0
	Local nPosEnt5    := 0
	Local nPosEnt6    := 0
	Local nPosEnt7    := 0
	Local nPosEnt8    := 0
	Local nPosEnt9    := 0
	Local nPosIdRef   := 0
	Local nPosTipo    := 0
	Local aRegs       := {}
	Local aProc       := {}
	Local nProcesso   := 0
	Local nCont       := 0
	Local cCodProc    := ""
	
	
	Private oProcesso
	Private cStrField
	Private cStrProcess
	
	Default aProcessos := {}

	// posiciona no processo
	If ! oXML:DOMChildNode()
		ConOut("elemento root nao possui processos")
		Return
	EndIf
	
	AAdd(aProc, oXML:DOMGetAttArray())

	For nProcesso := 1 To oXML:DOMChildCount()
		
		// pega o proximo itens
		If ! oXML:DOMChildNode()
			ConOut("elemento processo nao possui itens")
			Return
		EndIf
	
		AAdd(aProc, oXML:DOMGetAttArray())
		
		If ! oXML:DOMChildNode()
			ConOut("elemento itens nao possui item")
			Return
		EndIf
		
		AAdd(aRegs, oXML:DOMGetAttArray())  //para pegar a 1a. linha do xml da secao Itens
		
		While oXML:DOMNextNode()

			AAdd(aRegs, oXML:DOMGetAttArray())

		EndDo
	
		// voltando para o item
		oXML:DOMParentNode()
			
		// voltando para o processo
		oXML:DOMParentNode()
			
		// pega proximo processo
		oXML:DOMNextNode()
			
		// pega proximo item
		oXML:DOMNextNode()
	Next nProcesso
	
	For nCont := 1 To Len(aProc)
		nPosIdProc  := aScan(aProc[nCont],{|x|Upper(Alltrim(x[1]))== "IDPROCESSO" })
		If nPosIdProc > 0
			nProcess := nProcess + 1 //Resgato a quantidade de processos
		EndIf
	Next

	//-- Le os Processos do Arquivo
	For nI := 1 To nProcess
		
		nItens := 0
		
		uVarAux	:= aClone(aRegs)
		nItens		:= If( ValType(uVarAux)=="A",Len(aRegs),1)			
		
		For nCont := 1 To Len(aProc)
			nPosIdProc  := aScan(aProc[nCont],{|x|Upper(Alltrim(x[1]))== "IDPROCESSO" })
			If nPosIdProc > 0
				cCodProc := aProc [1][nPosIdProc][2] // Resgato o c๓digo do processo
			EndIf
		Next
		
		// ajustar que nao pode ser fixo
		aAdd(aProcessos,{	 cCodProc , {} })

		aItens := {}
		aItem  := {}

		//-- Le os Itens do Processo
		For nJ := 1 To nItens
			
			nPosIdProc  := aScan(aRegs[nj],{|x|Upper(Alltrim(x[1]))== "IDPROCESSO" })
			nPosDatPla  := aScan(aRegs[nj],{|x|Upper(Alltrim(x[1]))== "DTPLANEJ"   })
			nPosDatMov  := aScan(aRegs[nj],{|x|Upper(Alltrim(x[1]))== "DTPLANEJ"})//VERIFICAR A DATA CERTA
			nPosValor1  := aScan(aRegs[nj],{|x|Upper(Alltrim(x[1]))== "VALOR"      })
			nPosConta   := aScan(aRegs[nj],{|x|Upper(Alltrim(x[1]))== "CO"         })
			nPosClasse  := aScan(aRegs[nj],{|x|Upper(Alltrim(x[1]))== "CLASSE"     })
			nPosOper    := aScan(aRegs[nj],{|x|Upper(Alltrim(x[1]))== "OPER"       })
			nPosCcusto  := aScan(aRegs[nj],{|x|Upper(Alltrim(x[1]))== "CC"         })
			nPosItem    := aScan(aRegs[nj],{|x|Upper(Alltrim(x[1]))== "ITCTB"      })
			nPosClvlr   := aScan(aRegs[nj],{|x|Upper(Alltrim(x[1]))== "CLVLR"      })
			nPosUni     := aScan(aRegs[nj],{|x|Upper(Alltrim(x[1]))== "UNIORC"     })
			nPosEnt5    := aScan(aRegs[nj],{|x|Upper(Alltrim(x[1]))== "ENT05"      })
			nPosEnt6    := aScan(aRegs[nj],{|x|Upper(Alltrim(x[1]))== "ENT06"      })
			nPosEnt7    := aScan(aRegs[nj],{|x|Upper(Alltrim(x[1]))== "ENT07"      })
			nPosEnt8    := aScan(aRegs[nj],{|x|Upper(Alltrim(x[1]))== "ENT08"      })
			nPosEnt9    := aScan(aRegs[nj],{|x|Upper(Alltrim(x[1]))== "ENT09"      })
			nPosIdRef   := aScan(aRegs[nj],{|x|Upper(Alltrim(x[1]))== "IDREF"      })
			nPosTipo    := aScan(aRegs[nj],{|x|Upper(Alltrim(x[1]))== "TIPO"       })
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ  Foi definido que todos os campos do layout do arquivo XML devem ser         ณ
			//ณ  passados. Se o cliente nao utiliza algum campo opcional, o mesmo devera     ณ
			//ณ  ser passado com conteudo em branco. Caso algum campo nao seja passado,      ณ
			//ณ  sera gerado um errorlog interno, mas que o Begin Sequence omite e com o     ณ
			//ณ  tratamento do ErrorBlock, a tela de error log nao eh exibida para o usuario.ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			//bError := ErrorBlock({|| a009Error(@lRet)}) 
			
			aAdd(aItem,	{"AMJ_CHAVE"	,"XML-" + FWUUIDV1(.T.)                                 ,Nil})	//-- [01]: AMJ_CHAVE
			aAdd(aItem,	{"AMJ_DATPLA"	,CtoD(aRegs[nJ][nPosDatPla][2])							,Nil})	//-- [02]: AMJ_DATPLA
			aAdd(aItem,	{"AMJ_DATA"	    ,CtoD(aRegs[nJ][nPosDatMov][2])						    ,Nil})	//-- [03]: AMJ_DATA
			aAdd(aItem,	{"AMJ_VALOR1"	,Val (aRegs[nJ][nPosValor1][2])							,Nil})	//-- [04]: AMJ_VALOR
			aAdd(aItem,	{"AMJ_CO"		,PadR(aRegs[nJ][nPosConta ][2],Len(AMJ->AMJ_CO))		,Nil})	//-- [05]: AMJ_CO
			
		
			
			If nPosClasse > 0
				aAdd(aItem,	{"AMJ_CLASSE"	,PadR(aRegs[nJ][nPosClasse][2],Len(AMJ->AMJ_CLASSE))	,Nil})	//-- [06]: AMJ_CLASSE
			EndIf
			
			If nPosOper >0
				Iif(aOpcArqXml[1],aAdd(aItem,{"AMJ_OPER"  ,PadR(aRegs[nJ][nPosOper ][2] ,Len(AMJ->AMJ_OPER))  ,Nil}),Nil)	//-- [07]: AMJ_OPER
			EndIf
			
			If nPosCcusto > 0
				Iif(aOpcArqXml[2],aAdd(aItem,{"AMJ_CC"    ,PadR(aRegs[nJ][nPosCcusto][2],Len(AMJ->AMJ_CC))    ,Nil}),Nil)	//-- [08]: AMJ_CC
			EndIf
			
			If nPosItem > 0
				Iif(aOpcArqXml[3],aAdd(aItem,{"AMJ_ITCTB" ,PadR(aRegs[nJ][nPosItem][2]  ,Len(AMJ->AMJ_ITCTB)) ,Nil}),Nil)	//-- [09]: AMJ_ITCTB
			EndIf
			
			If nPosClvlr > 0
				Iif(aOpcArqXml[4],aAdd(aItem,{"AMJ_CLVLR" ,PadR(aRegs[nJ][nPosClvlr][2],Len(AMJ->AMJ_CLVLR)) ,Nil}),Nil)	//-- [10]: AMJ_CLVLR
			EndIf
												
			If nPosUni >0
				Iif(aOpcArqXml[5],aAdd(aItem,{"AMJ_UNIORC",PadR(aRegs[nJ][nPosUni][2]   ,Len(AMJ->AMJ_UNIORC)),Nil}),Nil)
			EndIf
			
			If nQtdEntid == NIL
				If cPaisLoc == "RUS"
					nQtdEntid := PCOQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor.
				Else
					nQtdEntid := CtbQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
				EndIf
			EndIf
            
			For nX := 5 to nQtdEntid
				cStrField	:= "AMJ_ENT"+StrZero(nX,2,0)
				Do Case
					Case nX == 5
						Iif(aOpcArqXml[nX+1],aAdd(aItem,{"AMJ_ENT"+StrZero(nX,2,0),PadR(aRegs[nJ][nPosEnt5][2],Len(AMJ->&(cStrField))),Nil}),Nil)
					Case nX == 6
						Iif(aOpcArqXml[nX+1],aAdd(aItem,{"AMJ_ENT"+StrZero(nX,2,0),PadR(aRegs[nJ][nPosEnt6][2],Len(AMJ->&(cStrField))),Nil}),Nil)
					Case nX == 7
						Iif(aOpcArqXml[nX+1],aAdd(aItem,{"AMJ_ENT"+StrZero(nX,2,0),PadR(aRegs[nJ][nPosEnt7][2],Len(AMJ->&(cStrField))),Nil}),Nil)
					Case nX == 8
						Iif(aOpcArqXml[nX+1],aAdd(aItem,{"AMJ_ENT"+StrZero(nX,2,0),PadR(aRegs[nJ][nPosEnt8][2],Len(AMJ->&(cStrField))),Nil}),Nil)
					Case nX == 9
						Iif(aOpcArqXml[nX+1],aAdd(aItem,{"AMJ_ENT"+StrZero(nX,2,0),PadR(aRegs[nJ][nPosEnt9][2],Len(AMJ->&(cStrField))),Nil}),Nil)
				EndCase
			Next nX
			
			aAdd(aItem,	{"AMJ_IDREF"	,PadR(aRegs[nJ][nPosIdRef][2],Len(AMJ->AMJ_IDREF))		,Nil})	//-- [11]: AMJ_IDREF
			aAdd(aItem,	{"AMJ_ID"		,StrZero(nJ % 10000,Len(AMJ->AMJ_ID))											,Nil})	//-- [12]: AMJ_ID
			aAdd(aItem,	{"AMJ_TIPO"	,PadR(aRegs[nJ][nPosTipo][2],Len(AMJ->AMJ_TIPO))			,Nil})	//-- [12]: AMJ_TIPO
			aAdd(aItem,	{"INDEX"		,2																		,Nil})	//-- [13]: Indice para pesquisa
            
			Aadd( aItens , aItem )
			aItem  := {}

			nPosData := aScan(aItens[Len(aItens)],{|x| x[1] == "AMJ_DATA" })
			If nPosData==0 .Or. aItens[Len(aItens)][nPosData][2] < dDtIni .Or. aItens[Len(aItens)][nPosData][2] > dDtFim
        		aAdd(aErros,"O Arquivo possui movimento fora do Periodo selecionado!  Processo: " + aProcessos[Len(aProcessos)][1] )
        		lRet := .F.
			EndIf
		Next nJ
		aProcessos[1][2] := aItens
	Next nI
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa009Error บAutor  ณMicrosiga           บ Data ณ  09/15/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para tratamento de erro para prote็ใo de falhas     บฑฑ
ฑฑบ          ณ dentro de um Begin Sequence                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PCOA009B                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function a009Error(lRet)
lRet := .F.
Break
Return
