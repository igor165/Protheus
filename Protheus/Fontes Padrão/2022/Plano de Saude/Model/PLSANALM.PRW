#INCLUDE "PLSANALM.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//� Define
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
#DEFINE PLS__ALIAS	 "B72"
#DEFINE PLS_MODELO 	 "PLSANALM"
#DEFINE PLS_MD__ID 	 "PLSANALMMD"
#DEFINE PLS_VW__ID	 "PLSANALMVI"

#DEFINE PLS_TITULO 	 STR0001 //"Analise"

#DEFINE PLS_VW_OPE  2
#DEFINE PLS_MD_OPE	 1
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSANALM
Classe modelo de dados da rotina de Auditoria (analise)

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
Class PLSANALM

METHOD New() Constructor

EndClass     
//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor da Class

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD New() Class PLSANALM
Return Self
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇旼컴컴컴컴컫컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽굇
굇쿑uncao    � MenuDef � Autor � Totvs                  � Data � 16.02.11 낢굇
굇쳐컴컴컴컴컵컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙굇
굇쿏escricao � MenuDef													  낢굇
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/
Static Function MenuDef()
LOCAL aSubMenu 	:= {}
LOCAL o790C	 	:= PLS790GEC() 
LOCAL cSetor	:= GETNEWPAR('MV_SETJNMD','ND')
Local lDUTGrid := PlsAliasExi("BKY")
PRIVATE aRotina := {}        

IF cSetor <> 'ND' .AND. (o790C:cCodDep $ cSetor) .AND. (B53->B53_JNTMED = "1")

	aAdd( aSubMenu, { STR0029 , "PLSJNTANX('1')" , 0, MODEL_OPERATION_INSERT} ) //Anexo I - Benefici�rio
	aAdd( aSubMenu, { STR0030 , "PLSJNTANX('2')" , 0, MODEL_OPERATION_INSERT} ) //Anexo II - M�dico Assistente
	aAdd( aSubMenu, { STR0031 , "PLSJNTANX('3')" , 0, MODEL_OPERATION_INSERT} ) //Anexo III - Convoca豫o
	aAdd( aSubMenu, { STR0032 , "PLSJNTANX('4')" , 0, MODEL_OPERATION_INSERT} ) //Anexo IV - Ata
	
	aAdd( aRotina, { STR0033, aSubMenu, 0, 0} ) //'Relacionados'
	
	aSubMenu 	:= {}
endif      
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//� Sub-Menu
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
If !o790C:lNegPar
	aAdd( aSubMenu, { STR0002, "PLS790VAO('13')",0, 0} ) //"Nivel da Critica"
	aAdd( aSubMenu, { STR0003, "PLS790VAO('14')",0, 0} ) //"Tabela Padrao"
	//Adicionando o Menu Relacionados da auditoria no menu A寤es Relacionadas da An�lise
	aAdd( aSubMenu, { STR0016, "PLS790VAO('1')", 0, 0} ) //"Contrato"
	aAdd( aSubMenu, { STR0017, "PLS790VAO('2')", 0, 0} ) //"Familia"
	aAdd( aSubMenu, { STR0018, "PLS790VAO('3')", 0, 0} ) //"Rda"
	aAdd( aSubMenu, { STR0019, "PLS790VAO('4')", 0, 0} ) //"Solicitante"
	aAdd( aSubMenu, { STR0020, "PLS790VAO('5')", 0, 0} ) //"Executante"
	aAdd( aSubMenu, { STR0021, "PLS790VAO('6')", 0, 0} ) //"Vlr. Cobranca"
	aAdd( aSubMenu, { STR0022, "PLS790VAO('7')", 0, 0} ) //"Movimentacao"
	aAdd( aSubMenu, { STR0023, "PLS790VAO('8')", 0, 0} ) //"Guia"
	aAdd( aSubMenu, { STR0024, "PLS790VAO('9')", 0, 0} ) //"Financeiro"
	aAdd( aSubMenu, { STR0025, "PLS790VAO('10')", 0, 0} ) //"Criticas"
	aAdd( aSubMenu, { STR0026, "PLS790VAO('11')", 0, 0} ) //"Grupo Caren"
	aAdd( aSubMenu, { STR0027, "PLS790VAO('12')", 0, 0} ) //"Classe Caren"
	aAdd( aSubMenu, { STR0028, "PLS790VAO('23')", 0, 0} ) //"Hist. Aud. Guia"

	If !lDUTGrid
		aAdd( aSubMenu, { STR0034, "PLS790VAO('24')", 0, 0} ) //"Dut"
	EndIF
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	//� aRotina
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	aAdd( aRotina, { STR0012 , 'PLS790ALS("' + PLS__ALIAS + '",  __oDlgAna  )' , 0, MODEL_OPERATION_INSERT} ) //'Parecer' 
	IF (o790C:lIncProc) .AND. !o790C:lRotinaGen //Verifica se usu�rio tem acesso para incluir procedimentos
	   aAdd( aRotina, {"INCLUIR", "PLSTESR()",0,0}) // Incluir 
	ENDIF
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	//� Sub-Menu
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	IIF ( !o790C:lRotinaGen, aAdd( aRotina, { STR0013, aSubMenu, 0, 0} ), "") //'Relacionados'
Else 
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	//� aRotina
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	aAdd( aRotina, { "Negar Partic." , 'PLS790NEG' , 0, MODEL_OPERATION_UPDATE} )
EndIf

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� P.E. utilizado para adicionar novas opcoes ao menu           �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
If ExistBlock("PLBOTADD")
	aBtAdd := ExecBlock("PLBOTADD",.F.,.F.,{aRotina})
	If ValType(aBtAdd) == "A"
		AEval(aBtAdd,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//� Fim da funcao															 
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	
Return aRotina
/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇旼컴컴컴컴컫컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽굇
굇쿑uncao    � ViewDef � Autor � Totvs                  � Data � 16.02.11 낢굇
굇쳐컴컴컴컴컵컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙굇
굇쿏escricao � ViewDef									  				  낢굇
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
/*/               
Static Function ViewDef()
LOCAL oModel := FWLoadModel( PLS_MODELO )
LOCAL oStruV := FWFormStruct( PLS_VW_OPE, PLS__ALIAS )
LOCAL oView  := FWFormView():New()
LOCAL o790C  := PLSA790C():New() 
LOCAL oPADC  := PLSPADRC():New(PLS__ALIAS) 
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//� Verifica se o perfil informado e da interna-saude
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

If !o790C:lIntSau
	oStruV:RemoveField( 'B72_INCONS' )
	oStruV:RemoveField( 'B72_TPPARE' )
	oStruV:RemoveField( 'B72_TPINCO' ) 
	oStruV:RemoveField( 'B72_DETPIC' ) 
	oStruV:RemoveField( 'B72_OBSISA' ) 
	If !GETNEWPAR('MV_EXPROC',.F.)
	  oStruV:RemoveField( 'B72_CODPRO' ) 
	  oStruV:RemoveField( 'B72_DESPRO' ) 
	EndIf
	oStruV:RemoveField( 'B72_CODGLO' ) 
	oStruV:RemoveField( 'B72_DESGLO' ) 
	oStruV:RemoveField( 'B72_RECMOV' )
	oStruv:RemoveField( 'B72_ALIMOV' )
	oStruv:RemoveField( 'B72_DATMOV' )	
//	oStruv:RemoveField( 'B72_CODPRO' )
	oStruv:RemoveField( 'B72_CODPAD' )	
	oStruv:RemoveField( 'B72_SEQPRO' )	
	oStruv:RemoveField( 'B72_ACOTOD' )
	oStruv:RemoveField( 'B72_RESAUT' )
	oStruv:RemoveField( 'B72_OPERAD' )
Else	
	oStruV:RemoveField( 'B72_NOMOPE' ) 
	If !GETNEWPAR('MV_EXPROC',.F.)
	  oStruV:RemoveField( 'B72_CODPRO' ) 
	  oStruV:RemoveField( 'B72_DESPRO' ) 
	EndIf 
	oStruV:RemoveField( 'B72_CODGLO' ) 
	oStruV:RemoveField( 'B72_DESGLO' ) 
	oStruV:RemoveField( 'B72_RECMOV' )
	oStruv:RemoveField( 'B72_ALIMOV' )
	oStruv:RemoveField( 'B72_DATMOV' )	
	//oStruv:RemoveField( 'B72_CODPRO' )
	oStruv:RemoveField( 'B72_CODPAD' )	
	oStruv:RemoveField( 'B72_SEQPRO' )	
	oStruv:RemoveField( 'B72_ACOTOD' )
	oStruv:RemoveField( 'B72_RESAUT' )
	oStruv:RemoveField( 'B72_OPERAD' )
EndIf 

If !o790C:lCriDia
	  oStruV:RemoveField( 'B72_DIASOL' ) 
	  oStruV:RemoveField( 'B72_DIAAUT' ) 
EndIf


//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Seta o modelo na visao													 
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
oView:SetModel( oModel )
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Adiciona a strutura de campos da tabela na view							 
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
oView:AddField( PLS_VW__ID, oStruV, PLS_MD__ID )   
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//� Fecha a tela
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
oView:SetCloseOnOk( {|oView| oPADC:VWOkCloseScreenVLD(oView,.F.) } )
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//� Validacao da view
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
oView:SetVldActivate( {|oView| oPADC:VWInitVLD(oView) } ) 
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Fim da rotina															 
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Return oView
/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇旼컴컴컴컴컫컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽굇
굇쿑uncao    � ModelDef� Autor � Totvs                  � Data � 16.02.11 낢굇
굇쳐컴컴컴컴컵컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙굇
굇쿏escricao � ModelDef									  				  낢굇
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
/*/
Static Function ModelDef()
LOCAL oPADC  := PLSPADRC():New(PLS__ALIAS) 
LOCAL oStruM := FWFormStruct( PLS_MD_OPE, PLS__ALIAS)
LOCAL oModel := MPFormModel():New( PLS_MODELO,/*bPreValidacao*/,{|oModel| oPADC:MDPosVLD(oModel,PLS__ALIAS) },{|oModel| oPADC:MDCommit(oModel,PLS__ALIAS) }, /*bCancel*/ )  /*bPosValidacao*/ /*bCommit*/ 
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Adiciona a strutura de campos ao modelo									 
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
oModel:AddFields( PLS_MD__ID,,oStruM )
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Defini a descricao da tela												 
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
oModel:SetDescription( PLS_TITULO )
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Valida o modelo															 
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
oModel:SetVldActivate( { |oModel| oPADC:MDActVLD(oModel) } )
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Fim da rotina															 
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Return oModel
/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽굇
굇쿑uncao    쿛LSANALM  � Autor � Totvs				    	� Data � 30/03/10 낢굇
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙굇
굇쿏escricao � Somente para compilar a class							  			낢굇
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
/*/
Function PLSANALM
Return
