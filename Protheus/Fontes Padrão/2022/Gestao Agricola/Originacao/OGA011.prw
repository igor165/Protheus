#INCLUDE "OGA011.ch"
#include "protheus.ch"
#include "fwmbrowse.ch"
#include "fwmvcdef.ch"

/** {Protheus.doc} OGA011
Rotina para vincular as moedas do Protheus x Moedas de sistemas externos

@param: 	Nil
@author: 	Rafael Kleestadt da Cruz
@since: 	16/06/2017
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGA011()
Local oMBrowse

//Atualiza a NJ7 conforme os parametros MV_MOEDA
GetMoed()

oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias( "NJ7" )
oMBrowse:SetDescription( STR0001 ) //"Moedas Protheus x Externas"
oMBrowse:Activate()

Return()

/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Rafael Kleestadt da Cruz
@since: 	16/06/2017
@Uso: 		OGA011 - Moedas Protheus x Externas
*/
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002 , 'PesqBrw'       , 0, 1, 0, .T. } ) //'Pesquisar'
aAdd( aRotina, { STR0003 , 'ViewDef.OGA011', 0, 2, 0, Nil } ) //'Visualizar'
aAdd( aRotina, { STR0005 , 'ViewDef.OGA011', 0, 4, 0, Nil } ) //'Alterar'
aAdd( aRotina, { STR0007 , 'ViewDef.OGA011', 0, 8, 0, Nil } ) //'Imprimir'
aAdd( aRotina, { STR0013 , 'OGA011ACM()', 0, 8, 0, Nil } ) //'Atualizar Cotação' 


Return aRotina

/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Rafael Kleestadt da Cruz
@since: 	16/06/2017
@Uso: 		OGA011 - Moedas Protheus x Externas
*/
Static Function ModelDef()
Local oStruNJ7 := FWFormStruct( 1, "NJ7" )
Local oModel   := MPFormModel():New( "OGA011M" )

oModel:AddFields( 'NJ7UNICO', Nil, oStruNJ7 )
oModel:SetPrimaryKey( { "NJ7_FILIAL", "NJ7_CODPRO" } )
oModel:SetDescription( STR0001 ) //'Moedas Protheus x Externas'
oModel:GetModel( 'NJ7UNICO' ):SetDescription( STR0009 ) //'Dados das Moedas Protheus x Externas'

Return oModel


/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	Rafael Kleestadt da Cruz
@since: 	16/06/2017
@Uso: 		OGA011 - Moedas Protheus x Externas
*/
Static Function ViewDef()
Local oStruNJ7 := FWFormStruct( 2, 'NJ7' )
Local oModel   := FWLoadModel( 'OGA011' )
Local oView    := FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_NJ7', oStruNJ7, 'NJ7UNICO' )
oView:CreateHorizontalBox( 'UM'  , 100 )
oView:SetOwnerView( 'VIEW_NJ7', 'UM'   )

Return oView

/** {Protheus.doc} GetMoed()
Função que busca a moeda protheus e carrega os dados em tela

@param: 	Nil
@return:	lRetorno - verdadeiro ou falso
@author: 	Rafael Kleestadt da Cruz
@since: 	16/06/2017
@Uso: 		OGA011 - Moedas Protheus x Externas
*/
Static Function GetMoed()
Local aMoedas    := {}	//Array com as moedas em uso
Local nX         := 0 
Local lRet       := .t.
Local aArrayNJ7  := OGA011QRY()

//Grava novos registros na NJ7 conforme parametros MV_MOEDA
For nX	:=	1 To MoedFin()
	If !Empty(AGRMVMOEDA(nX))
		AAdd(aMoedas, AGRMVMOEDA(nX))
	Else
		Exit
	Endif	
Next nX

For nX := 1 To Len(aMoedas)
	If aScan( aArrayNJ7, { |x| AllTrim( x[2] ) == aMoedas[nX] } ) == 0
		dbSelectArea("NJ7")
		NJ7->(dbSetOrder(1))
		If NJ7->(DbSeek(xFilial("NJ7") + Alltrim(STR(nX))))
			RecLock("NJ7", .F.)
			NJ7->(NJ7_DESCRI) := aMoedas[nX]
			NJ7->(NJ7_IDEXT1) := ""
			NJ7->(NJ7_IDEXT2) := ""
			("NJ7")->(MsUnLock())
		Else
			RecLock("NJ7", .T.)
			NJ7->(NJ7_CODPRO) := Alltrim(STR(nX))
			NJ7->(NJ7_DESCRI) := aMoedas[nX]
			("NJ7")->(MsUnLock())
		EndIf
	EndIf
Next nX

Return lRet

/** {Protheus.doc} ValMoeExt()
Função que valida o o codigo da moeda externa

@param: 	Nil
@return:	lRetorno - verdadeiro ou falso
@author: 	Rafael Kleestadt da Cruz
@since: 	16/06/2017
@Uso: 		OGA011 - Moedas Protheus x Externas
*/
Function ValMoeExt()
Local oModel 	 := FWModelActive()
Local nOperation := oModel:GetOperation()
Local cIdExt1	 := oModel:GetValue( "NJ7UNICO", "NJ7_IDEXT1" )
Local cIdExt2	 := oModel:GetValue( "NJ7UNICO", "NJ7_IDEXT2" )
Local cCodPro	 := oModel:GetValue( "NJ7UNICO", "NJ7_CODPRO" )
Local lRet  	 := .T.
Local cReadVar   := ReadVar()
Local aArrayNJ7  := OGA011QRY()
Local nX         := 0

If nOperation == MODEL_OPERATION_UPDATE 
	If cIdExt1 = cIdExt2 .and. !EMPTY( cIdExt1 ) .and. !EMPTY( cIdExt2 )
		Help( , , STR0010, , STR0012, 1, 0 )//'Ajuda!''Os códigos das moedas externas não podem ser iguais!'	
		Agrhelp(STR0010, STR0012 , STR0016) ////#'Ajuda!' #'Os códigos de moedas externos não podem ser iguais!' #"Informe uma codigo de moeda externa válida e que não esteja vinculada a nenhuma moeda do Protheus."
		lRet := .F.
	Else   
		If AllTrim(cReadVar) $ "M->NJ7_IDEXT1" 
			For nX := 1 To Len(aArrayNJ7)		
				If (aArrayNJ7[nX][3] == cIdExt1 .And. !Empty(cIdExt1) .And. !Empty(aArrayNJ7[nX][3]) .and. cCodPro != aArrayNJ7[nX][1] ) .Or.;
				   (aArrayNJ7[nX][4] == cIdExt1 .And. !Empty(cIdExt1) .And. !Empty(aArrayNJ7[nX][4]))  
					Agrhelp(STR0010, STR0011  , STR0016) ////#'Ajuda!' #'Código da moeda externa já vinculada em outra moeda do Protheus.' #"Informe uma codigo de moeda externa válida e que não esteja vinculada a nenhuma moeda do Protheus."
					lRet := .F.
				EndIf 
			Next nX
		Else
			For nX := 1 To Len(aArrayNJ7)
				If (aArrayNJ7[nX][3] == cIdExt2 .And. !Empty(cIdExt2) .And. !Empty(aArrayNJ7[nX][3])) .Or.;
				   (aArrayNJ7[nX][4] == cIdExt2 .And. !Empty(cIdExt2) .And. !Empty(aArrayNJ7[nX][4]) .and. cCodPro != aArrayNJ7[nX][1] )  
				    Agrhelp(STR0010, STR0011  , STR0016) ////#'Ajuda!' #'Código da moeda externa já vinculada em outra moeda do Protheus.' #"Informe uma codigo de moeda externo válido e que não esteja vinculado a nenhuma moeda do Protheus."
					lRet := .F.
				EndIf 
			Next nX
		EndIf
	EndIf
EndIf

Return ( lRet )

/** {Protheus.doc} ValMoeExt()
Função que retorna todos os dados da NJ7 no array aArrayNJ7

@param: 	Nil
@return:	aArrayNJ7
@author: 	Rafael Kleestadt da Cruz
@since: 	16/06/2017
@Uso: 		OGA011 - Moedas Protheus x Externas
*/
Static Function OGA011QRY()
Local aArrayNJ7	:= {}
Local cAliasTmp := GetNextAlias() //WorkArea Temporaria

	BeginSql alias cAliasTmp
			SELECT 
			    NJ7.NJ7_CODPRO,
				NJ7.NJ7_DESCRI,
				NJ7.NJ7_IDEXT1,
				NJ7.NJ7_IDEXT2
			FROM %table:NJ7% NJ7
			WHERE
				NJ7.%NotDel% AND
				NJ7.NJ7_FILIAL = %xFilial:NJ7%
				ORDER BY NJ7.R_E_C_N_O_                    
	EndSql    
	(cAliasTmp)->(DbGoTop())
	While (cAliasTmp)->(!Eof()) 
		aAdd( aArrayNJ7, { AllTrim((cAliasTmp)->NJ7_CODPRO), AllTrim((cAliasTmp)->NJ7_DESCRI), (cAliasTmp)->NJ7_IDEXT1, (cAliasTmp)->NJ7_IDEXT2 } ) 
		(cAliasTmp)->(dbSkip())
	EndDo
Return aArrayNJ7

/*/{Protheus.doc} OGA011ACM
Chama função de integração com a API M2M para atualizar as cotações das moedas 
@author claudineia.reinert
@since 07/06/2018
@version undefined

@type function
/*/
Function OGA011ACM()

	MsAguarde( {|| lRet := OGX300B(NJ7->NJ7_CODPRO) },STR0014,STR0015 )//"Aguarde" #"Atualizando cotações das moedas..." 
	

Return .T.