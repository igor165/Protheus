#INCLUDE "fata240.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static lRelease := GetRpoRelease() >= "R7"

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � FATA250  � Autor �Vendas & CRM           � Data �27.01.2012  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina de Manutencao do cadastro de Menus do Portal          ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � FATA250                                                      ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function Fata250()

Local aRotina := MenuDef()

If !lRelease
	mBrowse( 6, 1,22,75,"AI8")	
Else
	DEFINE FWMBROWSE oMBrowse ALIAS "AI8" DESCRIPTION STR0002 //"Menus dos Portais"
	ACTIVATE FWMBROWSE oMBrowse
EndIf

Return(.T.)

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Vendas & CRM          � Data �27/01/2012���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �	  1 - Pesquisa e Posiciona em um Banco de Dados			  ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef() 
	
Local aRotina	:= {}

	
FWMVCMenu( 'FATA250' )				
	
return (aRotina)

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    �ViewDef     � Autor �Vendas & CRM           � Data � 27/01/12 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Definicao da View                                          	���
���������������������������������������������������������������������������Ĵ��
���Retorno   � oView                                                       	���
���������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum														���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function ViewDef()
Local oModel 	 := FWLoadModel( 'FATA250')	// Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
Local oStruAI8 := FWFormStruct( 2, 'AI8' )	// Cria as estruturas a serem usadas na View
Local oView									// Interface de visualiza��o constru�da

oView := FWFormView():New()							// Cria o objeto de View
oView:SetModel( oModel )							// Define qual Modelo de dados ser� utilizado				
oView:AddField( 'VIEW_AI8', oStruAI8, 'AI8MASTER' )	// Adiciona no nosso View um controle do tipo formul�rio (antiga Enchoice)

// Cria um "box" horizontal para receber cada elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 100 )			

// Relaciona o identificador (ID) da View com o "box" para exibi��o
oView:SetOwnerView( 'VIEW_AI8', 'SUPERIOR' )			

Return oView

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    �ModelDef    � Autor �Vendas & CRM           � Data � 26/01/12 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Definicao do Model                                         	���
���������������������������������������������������������������������������Ĵ��
���Retorno   � oModel                                                      	���
���������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum														���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function ModelDef()
// Cria as estruturas a serem usadas no Modelo de Dados
Local oStruAI8 := FWFormStruct( 1, 'AI8' )	// Estrutura AI9
Local oModel 								// Modelo de dados constru�do

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'FATA250',NIL,NIL, {|oModel| A250Grava(oModel) })

// Adiciona ao modelo um componente de formul�rio
oModel:AddFields( 'AI8MASTER', /*cOwner*/, oStruAI8 )
// Retira obrigatoriedade do campo. Quando o menu � "pai", ele n�o possui webservice associado.
If Empty(AI8->AI8_CODPAI)
	oStruAI8:SetProperty( "AI8_WEBSRV", MODEL_FIELD_OBRIGAT , .F. )
EndIf
// Adiciona a descri��o do Modelo de Dados
oModel:SetDescription( STR0002 ) //"Menu dos Portais"
// Adiciona a descri��o dos Componentes do Modelo de Dados
oModel:GetModel( 'AI8MASTER' ):SetDescription( STR0002 ) 	//"Menu dos Portais"
// Retorna o Modelo de dados

oModel:SetPrimaryKey( { "AI8_FILIAL","AI8_PORTAL","AI8_CODMNU"} )

Return oModel


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A250Grava	� Autor � Vendas & CRM          � Data � 27.01.12 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava��o de Amarracao Menu x Portal                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � Void A250Grava(ExpO1)                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Model                                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A250Grava(oModel)

Local lRet := FWFormCommit(oModel)

If oModel:getOperation() == MODEL_OPERATION_INSERT
	FT240Grava()
EndIf

Return lRet


/*/{Protheus.doc} fValidOrg()
 - Utilizada para verificar se no Portal RH a vis�o a ser inclusa possui hier�rquia
 - Pois pelo RH h� a possibilidade de efetuar a inclus�o para avalia��o e pesquisa de Desempenho.
 - E Desta forma n�o conseguiria incluir a hier�rquia, fazendo com que as solicita��es fossem diretamente para o RH.
 @author:	Matheus Bizutti
 @since:  	01/07/2016 
 @return: 	Nil - Sem retorno de Dados.	
/*/
Function fValidOrg()

Local aArea 		:= GetArea()
Local cVision  		:= Iif( TYPE( "M->AI8_VISAPV" ) <> "U" .aND. !Empty(M->AI8_VISAPV) ,M->AI8_VISAPV,"" )
Local cPortal  		:= Iif(!Empty(AI8->AI8_PORTAL),AI8->AI8_PORTAL,"" )
Local cAliasRD4		:= "RD4"
Local nIndRD4		:= 4 // C�digo + Chave
Local cWhrRD4		:= ""
Local nRet 			:= 0
Local cFilRD4		:= xFilial("RD4")
Local lRet 			:= .T.
Local nReg			:= 0
Local cAliasQry		:= GetNextAlias()

DbSelectArea(cAliasRD4)
RD4->( DbSetOrder(nIndRD4) )

// - Portal RH
If Alltrim(cPortal) == "000006"
 
 	cWhrRD4 := "%"
	cWhrRD4 += "  RD4.RD4_FILIAL = '" + cFilRD4 + "' " 
	cWhrRD4 += "  AND RD4.RD4_CODIGO = '" + cVision + "' " 
	cWhrRD4 += "  AND ( (RD4.RD4_EMPIDE <> '' OR RD4.RD4_FILIDE <> '' OR RD4.RD4_CODIDE <> '') ) "
	cWhrRD4 += "%"

	BeginSql alias cAliasQry
		SELECT	COUNT(*) NITENS
		FROM %table:RD4% RD4
		WHERE 			   %exp:cWhrRD4% AND
	 	RD4.%notDel%   
	EndSql

	nReg := (cAliasQry)->NITENS
	(cAliasQry)->( DbCloseArea() ) 	
	 	
	If nReg == 0 .And. !Empty(cVision)
	   lRet := .F.
	EndIf
		
	If !lRet
		Help('',1,'Visao Aprova',,"Para as solicita��es do Portal RH, deve-se utilizar Estrutura Hierarquica: (SIGAORG)" + CRLF + CRLF + " - Empresa" + CRLF + " - Filial" + CRLF + " - Departamento" + CRLF + CRLF + " Verifique a Vis�o informada no campo (AI8_VISAPV)",1,0)
	EndIf
	
EndIf

RD4->( DbCloseArea() )
RestArea(aArea)

Return( lRet )