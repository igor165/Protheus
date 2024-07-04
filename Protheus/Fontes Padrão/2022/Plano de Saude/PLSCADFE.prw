#Include 'Protheus.ch'
#Include 'PLSCADFE.ch'
#Include 'FWMVCDEF.CH'
#Include "topconn.ch"
#Include "FWBROWSE.CH"

STATIC __aFreeDay	:= {} // armazena datas de verifica��o de feriados ja realizadas

//-------------------------------------------------------------------
/*/ {Protheus.doc} PLSCADFE
Tela de cadastro de feriados
@author Renan Martins
@since 08/2016
@version P12 
/*/
//-------------------------------------------------------------------
Function PLSCADFE()

Local oBrowse

//Instancia objeto
oBrowse := FWMBrowse():New()

//Define tabela de origem do Browse
oBrowse:SetAlias('B4T')

//Define nome da tela
oBrowse:SetDescription(STR0001) //"Cadastro de Feriados"

oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menus
@author Renan Martins
@since 08/2016
@version P12 
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

Add Option aRotina Title  STR0002	Action 'VIEWDEF.PLSCADFE' 	Operation 2 Access 0  //Visualizar
Add Option aRotina Title  STR0003 	Action "VIEWDEF.PLSCADFE" 	Operation 3 Access 0  //Incluir
Add Option aRotina Title  STR0004	Action "VIEWDEF.PLSCADFE" 	Operation 4 Access 0  //Alterar
Add Option aRotina Title  STR0005	Action "VIEWDEF.PLSCADFE"	Operation 5 Access 0  //Excluir
Add Option aRotina Title  STR0006	Action 'PLSVRMNESR(.f.)'	Operation 8 Access 0  //Replicar Feriado
Add Option aRotina Title  STR0017	Action 'PLSCADFE2'			Operation 8 Access 0  //Feriados da tabela SX5

Return aRotina



//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Defini��o do modelo de Dados.
@author Renan Martins
@since 08/2016
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel // Modelo de dados constru�do
Local oStrB4T	:= FWFormStruct(1,'B4T')// Cria as estruturas a serem usadas no Modelo de Dados, ajustando os campos que ir� considerar

oModel := MPFormModel():New( 'PLSCADFE', ,  { || PLSCADOK(oModel) }  ) // Cria o objeto do Modelo de Dados e insere a fun�ao de p�s-valida��o e de cancelamento

// Adiciona ao modelo um componente de formul�rio
oModel:AddFields( 'B4TMASTER', /*cOwner*/, oStrB4T )
 
// Adiciona a descri��o do Modelo de Dados
oModel:SetDescription( STR0001 )  //Cadastro de feriados

// Adiciona a descri��o dos Componentes do Modelo de Dados
oModel:GetModel( 'B4TMASTER' ):SetDescription( STR0001 )
oModel:SetPrimaryKey({"B4T_FILIAL", "B4T_DATA"})// + B4T_CODEST + B4T_FEFIXO + B4T_MESDIA})

Return oModel // Retorna o Modelo de dados



//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Defini��o da interface.
@author Renan Martins
@since 08/2016
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef() // Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
Local oView  // Interface de visualiza��o constru�da
Local oModel	:= FWLoadModel( 'PLSCADFE' ) // Cria as estruturas a serem usadas na View
Local oStrB4T	:= FWFormStruct(2,'B4T')

oModel:SetPrimaryKey( { "B4T_FILIAL","B4T_CODOPE","B4T_CODIGO" } )

// Cria o objeto de View
oView := FWFormView():New()

// Define qual Modelo de dados ser� utilizado
oView:SetModel( oModel )

// Adiciona no nosso View um controle do tipo formul�rio (antiga Enchoice)
oView:AddField( 'VIEW_B4T', oStrB4T, 'B4TMASTER' )

// Cria um "box" horizontal para receber cada elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 100 )

// Relaciona o identificador (ID) da View com o "box" para exibi��o
oView:SetOwnerView( 'VIEW_B4T', 'SUPERIOR' )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSCADOK
Valida a inclus�o do Registro.
@author Renan Martins
@since 08/2016
@version P12
/*/
//-------------------------------------------------------------------
Function PLSCADOK(oModel)
Local lRet			:= .T.
Local oB4T			:= oModel:getmodel("B4TMASTER")

IF ( oB4T:GetValue('B4T_TPFERI') == '0' .AND. Empty(oB4T:GetValue('B4T_CODEST')) )
	Help( ,, STR0007,, STR0008, 1, 0 )//"Aten��o" ## "Informe o Estado, pois a escolha do tipo de feriado foi Estadual!"
	lRet := .F.
ELSEIF ( oB4T:GetValue('B4T_TPFERI') == '1' .AND. Empty(oB4T:GetValue('B4T_CODMUN')) )
	Help( ,, STR0007,, STR0009, 1, 0 )//"Aten��o" ## "Informe o Munic�pio, pois a escolha do tipo de feriado foi Municipal!"
	lRet := .F.
ENDIF
IF ( Empty(oB4T:GetValue('B4T_DATA')) )
	Help( ,, STR0007,, STR0018, 1, 0 )//"Aten��o" ## "Informe a Data!"
	lRet := .F.
ENDIF	
Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} PLSVRMNESR
ParamBox com as op��es de r�plica
@author Renan Martins
@since 08/2016
@version P12
/*/
//-------------------------------------------------------------------
Function PLSVRMNESR(lAutoma)
Local aPergs 	:= {}
Local aRet 	:= {}

Local cCodLcD := IIF(B4T->B4T_TPFERI == '0', space(02), space(07) )
Local cCodLcA := IIF(B4T->B4T_TPFERI == '0', space(02), space(07) )
Local cStrD 	:= IIF(B4T->B4T_TPFERI == '0', STR0012, STR0010 )
Local cStrA 	:= IIF(B4T->B4T_TPFERI == '0', STR0013, STR0011 )
Local cPesq	:= IIF(B4T->B4T_TPFERI == '0', "12", "B57PLS" ) 
Local cTipo 	:= IIF(B4T->B4T_TPFERI == '0', "E", "M" )

Local lRet  	:= .F.
default lAutoma	:= .f.
  
aAdd( aPergs ,{1,cStrD,cCodLcD,"@!",'.T.',cPesq,'.T.',60,.F.})   
aAdd( aPergs ,{1,cStrA,cCodLcA,"@!",'.T.',cPesq,'.T.',60,.F.})

if !lAutoma
	If ParamBox(aPergs ,STR0007,aRet,,,.T.,256,129,,,.F.,.F.) 
		IF ( Empty(aRet[1]) .AND. Empty(aRet[2]) )
			MsgAlert(STR0016)
			Return lRet 
		ENDIF	
		IF (MsgYesNo(STR0014,STR0007) .AND. !Empty(aRet[1]) .AND. !Empty(aRet[2]) )     
			PLSRPFEUS(aRet[1],aRet[2], cTipo)
		ENDIF	
	 	lRet := .T.   
	EndIf
endif	
Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} PLSRPFEUS
Fun��o de r�plica de dados da Importa��o, conforme par�metros do usu�rio. 
@author Renan Martins
@since 08/2016
@version P12
/*/
//-------------------------------------------------------------------
Function PLSRPFEUS(cLocDE, cLocAT, cTipo)
Local nColB4T   	:= Len(B4T->(DbStruct()))
Local aDaDB4T 	:= {}
Local aLocais		:= {}
Local cLocAtual	:= IIF(cTipo == "M", B4T->B4T_CODMUN, B4T->B4T_CODEST)
Local nI			:= 0
Local nJ			:= 0
Local nK			:= 0

//Chamo fun��o para retornar municipios ou estados no intervalo selecionado
aLocais := PLSCHMNOES(cLocDE, cLocAT, cTipo)

aadd(aDaDB4T,Array(nColB4T))
For nI := 1 to nColB4T
	aDaDB4T[1,nI] := B4T->(FieldGet(nI))
Next
	
For nK := 1 To Len (aLocais)	
	For nI := 1 to Len(aDaDB4T) 
		IF aLocais[nK,1] <> cLocAtual  //N�o gravar o mesmo registro caso o intevalo contenha a cidade que originou o feriado) 
			
			If cTipo == "M"
				B4T->(DbSetOrder(2))
				If B4T->(MsSeek(xfilial("B4T") + aLocais[nK,1])) .AND. B4T->B4T_DATA == aDaDB4T[nI,5]
					Loop
				endIf			
			endIf
			
			B4T->(RecLock("B4T",.T.))
			For nJ := 1 To nColB4T
				B4T->(FieldPut(nJ,aDaDB4T[nI,nJ]))
			Next
			IIF ( cTipo == "M", B4T->B4T_CODMUN := aLocais[nK,1], B4T->B4T_CODEST := aLocais[nK,1])
			B4T->(Msunlock())
		ENDIF	
	Next
Next	
MsgAlert(STR0015)  //"R�plica realizada com sucesso!"
Return 



//-------------------------------------------------------------------
/*/{Protheus.doc} PLSCHMNOES
Fun��o para verificar na BID ou SX5 - 12 os estados/munic�pios que est�o no intervalo definido pelo usu�rio para r�plica
@author Renan Martins
@since 08/2016
@version P12
/*/
//-------------------------------------------------------------------
Function PLSCHMNOES(cLocDE, cLocAT, cTipo)
Local cSql 	:= ""
Local aResult	:= {}	

IF cTipo == "M"
	cSql := " SELECT BID_CODMUN CODMUN"
	cSql += " FROM " + RetSQLName("BID")
	cSql += " WHERE BID_FILIAL = '" + xFilial("BID") + "' AND BID_CODMUN >= '" + cLocDE + "' "
	cSql += " AND BID_CODMUN <= '" + cLocAT + "' "
	cSql += " AND D_E_L_E_T_ = ' ' "
ELSE
	cSql := " SELECT X5_CHAVE ESTADO"
	cSql += " FROM " + RetSQLName("SX5")
	cSql += " WHERE X5_TABELA = '12' "
	cSql += " AND X5_CHAVE >= '" + cLocDE + "' "
	cSql += " AND X5_CHAVE <= '" + cLocAT + "' "
	cSql += " AND D_E_L_E_T_ = ' ' "
ENDIF

cSql	:= ChangeQuery(cSql)
TcQuery cSql New Alias "TResult"

While ! TResult->(Eof())
	aadd(aResult,{IIF(cTipo == "M", AllTrim(TResult->CODMUN), AllTrim(TResult->ESTADO))})
	TResult->(DbSkip())
Enddo

TResult->(DBCLOSEAREA())
		
Return aResult


//-------------------------------------------------------------------
/*/{Protheus.doc} PlsDcLocl
Localiza os locais de Atendimento e mantem array de reaproveitamento em memoria (performance) o VLRPRO por exemplo pra cada item chama duas vezes essa fun��o
@author Renan Martins
@since 08/2016
@version P12
/*/
//-------------------------------------------------------------------
Function PlsDcLocl(cCodRDA, cCodLoc, dData)
Local cOperad 	:= PLSINTPAD()
Local cCodMun 	:= ""
Local cCodEst 	:= ""
Local lRetF		:= .F.
Local nPos		:= 0

Default cCodRDA 	:= ""
Default cCodLoc 	:= ""

If (nPos := Ascan(__aFreeDay,{ |x| x[1] == cCodRDA+cCodLoc+DTOS(dData) })) == 0 // Se nao verifiquei esse dia ainda insiro no meu array de reaproveitamento
	AaDd(__aFreeDay, {cCodRDA+cCodLoc+DTOS(dData), .F.})
Else //Achei, ent�o nem vou na base mais
	Return __aFreeDay[nPos, 2]
EndIf 

IF ( !Empty(cCodRDA) .AND. !Empty(cCodLoc) )
	BB8->(DbSetOrder(1))  //FILIAL+CODIGO+CODINT+CODLOC+LOCAL
	IF ( BB8->(dbseek(xFilial("BB8") + cCodRDA + cOperad + cCodLoc)) )
		cCodMun := BB8->BB8_CODMUN
		cCodEst := BB8->BB8_EST
		lRetF 	 := PlsChFerME(cCodMun, cCodEst, dData)
	ENDIF	
ENDIF

__aFreeDay[Len(__aFreeDay), 2] := lRetF
	
Return lRetF



//-------------------------------------------------------------------
/*/{Protheus.doc} PlsChFerME
Fun��o que vai verificar na B4T se existe o feriado para o local de atendimento.
@author Renan Martins
@since 08/2016
@version P12
/*/
//-------------------------------------------------------------------
Function PlsChFerME(cCodMun, cCodEst, dData)
Local lRet		:= .F.
Local cSqlFE	:= ""
Local cSubStr	:= IIF( AllTrim( TCGetDB() ) $ "ORACLE/DB2/POSTGRES" , 'SUBSTR', 'SUBSTRING')

cSqlFE += " SELECT 1  "
cSqlFE += " FROM " + retSQLName("B4T")
cSqlFE += " WHERE B4T_FILIAL = '" + xFilial("B4T") + "' "
cSqlFE += " AND  ( "
cSqlFE += " (B4T_TPFERI = '1' AND B4T_CODMUN = '" + cCodMun + "') OR " //Condi��o para feriado municipal
cSqlFE += " (B4T_TPFERI = '0' AND B4T_CODEST = '" + cCodEst + "' ) " //Condi��o para feriado estadual
cSqlFE += " ) "
cSqlFE += " AND ( "
cSqlFE += " ( B4T_FEFIXO = '1' AND " + cSubStr + "(B4T_DATA,5,4) = '" + MESDIA(dData) + "' ) OR " //Condi��o para feriado fixo (tipo Natal, sempre mesmo dia e m�s de todo ano)
cSqlFE += " ( B4T_FEFIXO = '0' AND B4T_DATA = '"+dtos(dData)+"' ) " //Condi��o para feriado vari�vel (tipo carnaval, cada ano � num dia)
cSqlFE += " ) AND D_E_L_E_T_ = ' ' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSqlFE),"PLSCHFE",.F.,.T.)

if !PLSCHFE->(eof())
	lRet := .T.
ENDIF
PLSCHFE->(DbCloseArea())

Return lRet