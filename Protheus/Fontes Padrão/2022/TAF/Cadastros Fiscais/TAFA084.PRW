#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"    
#INCLUDE "TAFA084.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA084
Cadastro MVC - Contribuicao Social Extemporanea PIS/PASEP/COFINS

@author Rodrigo Aguilar
@since 17/08/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA084
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //"Contribuição Social Extemporânea Pis/Pasep/Cofins"
oBrw:SetAlias( 'C5J' )
oBrw:SetMenuDef( 'TAFA084' )
oBrw:Activate()  

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu
@author Denis R de Oliveira
@since 17/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf084Vld" , "2" } )
aRotina	:=	xFunMnuTAF( "TAFA084" , , aFuncao )

Return( aRotina )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Rodrigo Aguilar
@since 17/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC5J 	:= 	FWFormStruct( 1, 'C5J' )
Local oStruC5K 	:= 	FWFormStruct( 1, 'C5K' )
Local oStruC5L 	:= 	FWFormStruct( 1, 'C5L' )
Local 	oModel 	:=  MPFormModel():New( 'TAFA084' , , , {|oModel| SaveModel( oModel ) } )
      
oModel:AddFields('MODEL_C5J', /*cOwner*/, oStruC5J )

oModel:AddGrid('MODEL_C5K', 'MODEL_C5J', oStruC5K)  
oModel:GetModel( 'MODEL_C5K' ):SetUniqueLine( { 'C5K_CNPJ', 'C5K_CSTPC', 'C5K_CDPAR', 'C5K_DTOPER' } )

oModel:AddGrid('MODEL_C5L', 'MODEL_C5J', oStruC5L)   
oModel:GetModel( 'MODEL_C5L' ):SetUniqueLine( { 'C5L_PERACR', 'C5L_ORGCRD', 'C5L_CODCRE' } )

oModel:SetRelation( 'MODEL_C5K' , { { 'C5K_FILIAL' , 'xFilial( "C5K" )' } , { 'C5K_ID' , 'C5J_ID' } } , C5K->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C5L' , { { 'C5L_FILIAL' , 'xFilial( "C5L" )' } , { 'C5L_ID' , 'C5J_ID' } } , C5L->( IndexKey( 1 ) ) )

oModel:GetModel( "MODEL_C5J" ):SetPrimaryKey( { "C5J_PERMOV", "C5J_TPTRB", "C5J_PERAPR", "C5J_CNATC" } )                                                                                                      

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Rodrigo Aguilar
@since 17/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef() 

Local oModel 	:= 	FWLoadModel( 'TAFA084' )
Local oStruC5J 	:= 	FWFormStruct( 2, 'C5J' ) //Cred.ICMS sobre Ativo Perman
Local oStruC5K 	:= 	FWFormStruct( 2, 'C5K' ) //Movto.Bem.Comp.Atv.Imobilizado
Local oStruC5L 	:= 	FWFormStruct( 2, 'C5L' ) //Outros Créditos CIAP
Local oView 	:= 	FWFormView():New()

oView:SetModel( oModel )

oView:AddField( 'VIEW_C5J', oStruC5J, 'MODEL_C5J' )
oView:EnableTitleView( 'VIEW_C5J', STR0001) //"Contribuicao Social Extemporanea - PIS/PASEP/Cofins"

oView:AddGrid ( 'VIEW_C5K', oStruC5K, 'MODEL_C5K' )
oView:AddGrid ( 'VIEW_C5L', oStruC5L, 'MODEL_C5L' )

oView:CreateHorizontalBox( 'FIELDSC5J', 30 )          

oView:CreateHorizontalBox( 'PANFOLDER1', 70 )
oView:CreateFolder( 'FOLDER1', 'PANFOLDER1' )

oView:AddSheet( 'FOLDER1', 'ABA01', STR0002) //"Detalhamento da Contribuição Social Extemporânea"
oView:AddSheet( 'FOLDER1', 'ABA02', STR0003) //"Demonstração do crédito a Descontar da Contribuição Extemporânea"
oView:CreateHorizontalBox( 'GRIDC5K', 100,,, 'FOLDER1', 'ABA01' )
oView:CreateHorizontalBox( 'GRIDC5L', 100,,, 'FOLDER1', 'ABA02' )

If TamSX3("C5K_CODCTA")[1] == 36
	oStruC5K:RemoveField( "C5K_CODCTA")
	oStruC5K:SetProperty( "C5K_CTACTB", MVC_VIEW_ORDEM, "13" )
EndIf   
If TamSX3("C5K_CDPAR")[1] == 36
	oStruC5K:RemoveField( "C5K_CDPAR")
	oStruC5K:SetProperty( "C5K_PARTIC", MVC_VIEW_ORDEM, "07" )
EndIf   
oView:SetOwnerView( 'VIEW_C5J', 'FIELDSC5J' )
oView:SetOwnerView( 'VIEW_C5K', 'GRIDC5K' )
oView:SetOwnerView( 'VIEW_C5L', 'GRIDC5L' )

Return oView     


//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Denis R. de Oliveira
@since 17/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

Local nOperation := oModel:GetOperation()

Begin Transaction

	If nOperation == MODEL_OPERATION_UPDATE
		//³Funcao responsavel por setar o Status do registro para Branco³
		TAFAltStat( "C5J", " " )	
	EndIf
	FwFormCommit( oModel )
End Transaction
       
Return .T.
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} TAF084Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacões caso seja necessario gerar um XML

lJob - Informa se foi chamado por Job

@return .T.

@author Denis R. de Oliveira
@since 18/02/2014
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function TAF084Vld(cAlias,nRecno,nOpc,lJob)
Local nSomaVLRPC := 0
Local aLogErro	:= {}
Local aCarc_Esp := {}
Local cPerApSl  := AllTrim(C5J->C5J_PERAPR)
Local cPeriodo  := " " 
Local i

Default lJob := .F.

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C5J->( Recno() )

If C5J->C5J_STATUS $ ( " |1" )
	
	
	If Empty(C5J->C5J_PERMOV)
		AADD(aLogErro,{"C5J_PERMOV","000010","C5J", nRecno }) //STR0010 - //Campo Inconsistente ou Vazio	
	EndIF
	
	If Empty(C5J->C5J_PERAPR)
		AADD(aLogErro,{"C5J_PERAPR","000010","C5J", nRecno }) //STR0010 - //Campo Inconsistente ou Vazio	
	EndIF
	
	If Empty(C5J->C5J_VLOUTD)
		AADD(aLogErro,{"C5J_VLOUTD","000010","C5J", nRecno }) //STR0010 - //Campo Inconsistente ou Vazio	
	EndIF
	
	//Tipo do Tributo
	If !(C5J->C5J_TPTRB $ ("1|2"))
		AADD(aLogErro,{"C5J_TPTRB","000006","C5J", nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
	EndIF
	
	//Valida se o periodo de apuracao saldo extemp está no formato MMAAAA
	If (Left(cPerApSl,2) < "01" .Or. Left(cPerApSl,2) > "12") .Or. (Substr(cPerApSl,3,4) < "1949" .Or. Substr(cPerApSl,3,4) > "2049") .Or. Len(cPerApSl) <> 6 //Formato MMAAAA
		
		AADD(aLogErro,{"C5J_PERAPR","000554","C5J", nRecno }) //STR0554 - "Informar o periodo no formato mês/ano(MMAAAA)" 
		
	EndIf
	
	//Imputa os Caracteres Especiais no Array de Controle
	AADD(aCarc_Esp,{"!", "Exclamacao"})
	AADD(aCarc_Esp,{"@", "Arroba"})
	AADD(aCarc_Esp,{"#", "Sustenido"})
	AADD(aCarc_Esp,{"$", "Cifrao"})
	AADD(aCarc_Esp,{"%", "Porcentagem"})
	AADD(aCarc_Esp,{"*", "Asterisco"})
	AADD(aCarc_Esp,{"/", "Barra"})
	AADD(aCarc_Esp,{"(", "Parentese"})
	AADD(aCarc_Esp,{")", "Parentese"})
	AADD(aCarc_Esp,{"+", "Mais"})
	AADD(aCarc_Esp,{"¨", ""})
	AADD(aCarc_Esp,{"=", "Igual"})
	AADD(aCarc_Esp,{"~", "Til"})
	AADD(aCarc_Esp,{"^", "Circunflexo"})
	AADD(aCarc_Esp,{"]", "Chave"})
	AADD(aCarc_Esp,{"[", "Chave"})
	AADD(aCarc_Esp,{"{", "Colchete"})
	AADD(aCarc_Esp,{"}", "Colchete"})
	AADD(aCarc_Esp,{";", "Ponto e Virgula"})
	AADD(aCarc_Esp,{":", "Dois Pontos"})
	AADD(aCarc_Esp,{">", "Maior"})
	AADD(aCarc_Esp,{"<", "Menor"})
	AADD(aCarc_Esp,{"?", "Interrogacao"})
	AADD(aCarc_Esp,{"_", "Underline"})
	AADD(aCarc_Esp,{",", "Virgula"})
	AADD(aCarc_Esp,{" ", "Espaco"})
	AADD(aCarc_Esp,{"'", "Aspas"})
	
	//Verifica se o periodo contém algum caracter especial
	For i:= 1 to Len(aCarc_Esp)
		If At(aCarc_Esp[i,1], cPerApSl) <> 0
			AADD(aLogErro,{"C5J_PERAPR","000516","C5J", nRecno }) //STR0516 - "O campo periodo possui caracteres especiais"
		EndIf
	Next
	
	//Natureza da Contribuicao
	If !Empty(C5J->C5J_CNATC)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C5J->C5J_CNATC
		xValRegTab("C1C",cChave,3,,@aLogErro,, { "C5J", "C5J_CNATC", nRecno } )
	EndIf
		
	//Valida a Grid Detalhamento da contribuição social extemporânea        
	cDtIni:= Posicione("C1E",3,xFilial("C1E")+Alltrim(SM0->M0_CODFIL)+"1","C1E_DTINI")//Recebe o Periodo Inicial da Validade do complemento de empresa
	
	dbSelectArea("C5K")
	C5K->(dbSetORder(1))
	If C5K->(MsSeek(xFilial("C5K") + C5J->C5J_ID))
		cId:=C5K->C5K_ID
		nSomaVLRPC := 0
		
		While (!C5K->(Eof()) .And. cId==C5K->C5K_ID)
			
			//CNPJ
			If Len(AllTrim(C5K->C5K_CNPJ)) <> 14 .Or. !CGC(AllTrim(C5K->C5K_CNPJ), , .F.)
				aAdd(aLogErro,{'C5K_CNPJ','000005','C5J',nRecno})		//STR0005 - CPF/CNPJ Inconsistente
				
			EndIf
			
			//Cod.Sit.Trib.Pis/Cofins
			If !Empty(C5K->C5K_CSTPC)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C5K->C5K_CSTPC
				xValRegTab("C17",cChave,3,,@aLogErro,, { "C5J", "C5K_CSTPC", nRecno })
			EndIf
			
			//Id. Participante
			If !Empty(C5K->C5K_CDPAR)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C5K->C5K_CDPAR
				xValRegTab("C1H",cChave,5,,@aLogErro,, { "C5J", "C5K_CDPAR", nRecno })
			EndIf
			
			//Cod. Conta Contabil
			If !Empty(C5K->C5K_CODCTA)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C5K->C5K_CODCTA
				xValRegTab("C1O",cChave,3,,@aLogErro,, { "C5J", "C5K_CODCTA", nRecno })
			EndIf
			
						
			If Empty(C5K->C5K_DTOPER)
				AADD(aLogErro,{"C5K_DTOPER","000010","C5J", nRecno }) //STR0010 - //Campo Inconsistente ou Vazio	
			EndIF
						
			If Empty(C5K->C5K_VLOPER)
				AADD(aLogErro,{"C5K_VLOPER","000010","C5J", nRecno }) //STR0010 - //Campo Inconsistente ou Vazio	
			EndIF
						
			If Empty(C5K->C5K_VLBCPC)
				AADD(aLogErro,{"C5K_VLBCPC","000010","C5J", nRecno }) //STR0010 - //Campo Inconsistente ou Vazio	
			EndIF
						
			If Empty(C5K->C5K_ALQPC)
				AADD(aLogErro,{"C5K_ALQPC","000010","C5J", nRecno }) //STR0010 - //Campo Inconsistente ou Vazio	
			EndIF
						
			If Empty(C5K->C5K_VLRPC)
				AADD(aLogErro,{"C5K_VLRPC","000010","C5J", nRecno }) //STR0010 - //Campo Inconsistente ou Vazio	
			EndIF
					
			nSomaVLRPC := C5K->C5K_VLRPC
			
			C5K->(dbSkip())
					
		Enddo
		
		If nSomaVLRPC <> C5J->C5J_VLCTAP
			AADD(aLogErro,{"C5J_VLCTAP","000589","C5J", nRecno }) //STR0589 - "O valor da contribuição apurada deve ser igual a soma dos valores do campo Vlr. PC"
		EndIF
		
		
	Endif
	
	//Valida a Grid Demostração do crédito a descontar da contribuição extemporânea 
	
	dbSelectArea("C5L")
	C5L->(dbSetORder(1))
	If C5L->(MsSeek(xFilial("C5L") + C5J->C5J_ID))
		cId:=C5L->C5L_ID
		While (!C5L->(Eof()) .And. cId==C5L->C5L_ID)
			
			//Origem do Credito
			If !(C5L->C5L_ORGCRD $ ("01|02"))
				AADD(aLogErro,{"C5L_ORGCRD","000006","C5J", nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
			EndIF
			
			cPeriodo:= AllTrim(C5L->C5L_PERACR)
			
			//Valida se o periodo de apuracao de credito está no formato MMAAAA
			If (Left(cPeriodo,2) < "01" .Or. Left(cPeriodo,2) > "12") .Or. (Substr(cPeriodo,3,4) < "1949" .Or. Substr(cPeriodo,3,4) > "2049") .Or. Len(cPeriodo) <> 6 //Formato MMAAAA
				
				AADD(aLogErro,{"C5L_PERACR","000554","C5J", nRecno }) //STR0554 - "Informar o mˆs/ano (formato MMAAAA)
				
			EndIf
			
			//Verifica se o periodo contém algum caracter especial
			For i:= 1 to Len(aCarc_Esp)
				If At(aCarc_Esp[i,1], cPeriodo) <> 0
					AADD(aLogErro,{"C5L_PERACR","000516","C5J", nRecno }) //STR0516 - "O campo periodo possui caracteres especiais"
				EndIf
			Next
			
			//Verifica se o período informado no campo é anterior ou igual ao período de apuração
			If !(Substr(cPeriodo,3,4) <= Substr(cPerApSl,3,4))
				AADD(aLogErro,{"C5L_PERACR","000384","C5J", nRecno }) //STR0384 - "A data deve ser anterior ou igual ao período de apuração ao qual se refere o arquivo." 
			EndIF 
			
			If (Substr(cPeriodo,3,4) == Substr(cPerApSl,3,4)) 
				If !(Left(cPeriodo,2) <= Left(cPerApSl,2))
					AADD(aLogErro,{"C5L_PERACR","000384","C5J", nRecno }) //STR0384 - "A data deve ser anterior ou igual ao período de apuração ao qual se refere o arquivo." 
				EndIf 
			EndIf 
			
			//Codigo do Tipo do Credito
			If !Empty(C5L->C5L_CODCRE)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C5L->C5L_CODCRE
				xValRegTab("C4D",cChave,3,,@aLogErro,, { "C5J", "C5L_CODCRE", nRecno } )
			EndIf
				
			If Empty(C5L->C5L_VLCRED)
				AADD(aLogErro,{"C5L_VLCRED","000010","C5J", nRecno }) //STR0010 - //Campo Inconsistente ou Vazio	
			EndIF
					
			
			C5L->(dbSkip())
			
		Enddo
		
	Endif
	
	//ATUALIZO O STATUS DO REGISTRO
	If Len(aLogErro)>0
		//Utilizo RecLock, pois o SETVALUE somente funciona em campos USADOS
		RecLock("C5J",.F.)
			C5J->C5J_STATUS := "1"
		C5J->( MsUnlock() )
	Else
		RecLock("C5J",.F.)
			C5J->C5J_STATUS := "0"
		C5J->( MsUnlock() )
	EndIf
	
Else
	AADD(aLogErro,{"C5J_ID","000305", "C5J", nRecno })//Registros que já foram transmitidos ao Fisco, não podem ser validados
EndIf

//Não apresento o alert quando utilizo o JOB para validar³
If !lJob
	xValLogEr(aLogErro)
EndIf

Return(aLogErro)
