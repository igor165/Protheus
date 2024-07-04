#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TBICONN.CH"      
#INCLUDE "LOJXFUNH.CH"

//DEFINEs utilizados na rotina de otimizacao de tabela
#DEFINE ARQUIVO		"LJLIMPTB.ini"
#DEFINE SECAO		"otimizacao_tabela"
#DEFINE DT_VER		"dt_verificacao"
#DEFINE DT_EXE		"dt_execucao"

Static aRecSaldo	:= {}														//Array que armazenara o saldo inserido no cartao fidelidade
Static lR5			:= GetRpoRelease("R5")										//Release 11.5 Ativo
Static lLjcFid		:= SuperGetMv("MV_LJCFID",,.F.) .AND. CrdxInt() .AND. lR5	//Indica se a recarga de cartao fidelidade esta ativa

Static oProcess		//objeto MsNewProcess utilizado na rotina referente a Otimizacao de Tabelas
 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³LojxFunH  ³ Autor ³ Leandro Nogueira	    ³ Data ³ 22/11/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Recarga de saldo no cartao fidelidade					  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ExpL1:=LojxFunH()				 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 		 													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1 = NIL												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³LOJA701/FRTA271										      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function LojxFunH()
Return Nil
                  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³MenuDef	³ Autor ³ Leandro Nogueira	    ³ Data ³ 22/11/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³MenuDef - MVC												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ExpA1:=MenuDef()				 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 		 													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1 = aRotina											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³LOJA701/FRTA271										      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function MenuDef()
Local aRotina := {}
ADD OPTION aRotina TITLE STR0001 ACTION 'VIEWDEF.LOJXFUNH' OPERATION 3 ACCESS 0 //"Incluir"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
Return aRotina


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³LaFunhInc ³ Autor ³ Leandro Nogueira	    ³ Data ³ 22/11/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Chama a tela de recarga de cartao fidelidade				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ExpL1:=LaFunhInc(lExp1,cExp2,dExp3,nExp4)					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³lExp1 - Indica se a tela esta sendo chamada durante a 	  ³±±
±±³			 ³importacao de um orcamento.						          ³±±
±±³			 ³cExp2 - Numero do Cartao Fidelidade				          ³±±
±±³			 ³dExp3 - Data de validade da recarga				          ³±±
±±³			 ³nExp4 - Valor da recarga							          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1 = .T.												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³LOJA701												      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/      

Function LaFunhInc (lImpOrc,cNumCar,dValidade,nValor,cCodCli,cLoja)

Local lRet		:= .F.			
Local cMoeda	:= SuperGetMv("MV_SIMB1")	// Simbolo da moeda principal 
Local aCarFid   := {}

DEFAULT lImpOrc		:= .F. 
DEFAULT cNumCar		:= ""
DEFAULT cLoja		:= ""
DEFAULT dValidade 	:= ""
DEFAULT nValor	 	:= 0
DEFAULT cCodCli     := 0

If lImpOrc .AND. !Empty(cNumCar) .AND. !Empty(dValidade) .AND. nValor > 0
	aADD(aRecSaldo,{cNumCar,dValidade,nValor})
Endif

If !AliasIndic("MBO") .OR. !AliasIndic("MBP") .OR. !AliasIndic("MBN")
	MsgStop (STR0002)//"Uma ou mais tabelas do processo de recarga do cartão fidelidade não foram encontradas"
	Return lRet
EndIf

If (!lImpOrc .AND. Len (aRecSaldo) == 0) .OR. (lImpOrc)// .AND. Len (aRecSaldo) > 0)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso Seja 11.5 e Cartão Fidelidade Ativo.                          ³
	//³Verifica se o Cartão não está preenchido na tela e se o            ³
	//³código do cliente não é vazio. e realiza a procura pelas           ³
	//³informações do Cartão Fidelidade através da                        ³
	//³Função CA280CONCL                                                  ³
	//³Le o Array a CarFid com informacoes do Cartao Atrelado ao Cliente e³
	//³realiza pergunta se o cliente deseja utilizá-lo.                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lLjcFid
		If Empty(cNumCar) .AND. !Empty(cCodCli)
   			lRet := Ca280Exec (  "CA280CONCL",Nil, 	Nil,  Nil,;
   											Nil  ,  Nil,  cLoja,	Nil,;	
		 									Nil  ,  cCodCli)
			If Len(CA280GetAr()) > 0
				//Ler o Array com informacoes do Cartao Atrelado ao Cliente.
				aCarFid 	:= CA280GetAr()
				cNumCar		:=(aCarFid[1][1])
				dValidade	:=(aCarFid[1][2])
				If MsgYesNo(STR0011+CHR(13)+STR0012+cNumCar) //Deseja Utilizar o Cartão Fidelidade para este Cliente				
					If Empty(nValor)
						nValor := 0
					EndIf
					aADD(aRecSaldo,{cNumCar,dValidade,nValor})
  	    		EndIf
			EndIf	  								
    	EndIf
    EndIf
    //"Recarga de cartão fidelidade"
    FWExecView(STR0003,'LOJXFUNH', 3, , { ||lRet:=.T., lRet},,35 )
	//
	If lRet
		If !MsgYesNo (STR0004 + LaFunhGet(1) + STR0005 + AllTrim(cMoeda) + " " + AllTrim(Transform(LaFunhGet(3),AvSx3("MBP_VALOR", 6))) + " ?")//"Deseja realmente incluir o saldo para o Cartão " #//" no valor de " 
			MsgStop( STR0006 )//"Operação cancelada."
			LaFunhDelS()
			lRet := .F.
		EndIf
	Else
   		LaFunhDelS()		
   		lRet := .F.
	EndIf
	
EndIf
	
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ModelDef  ³ Autor ³ Leandro Nogueira	    ³ Data ³ 22/11/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³MVC - Camada de modelo de dados						 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ExpO1:=ModelDef()			 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 		 													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1 = oModel											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³LOJA701/FRTA271										      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function ModelDef()

Local oStruMBP 	:= FWFormStruct( 1, 'MBP')
Local oModel 	:= MPFormModel():New('LOJXFUNHMODEL',,,{|oModel| LaFunhCmm(oModel)}) 

oModel:AddFields('MBPDETAIL',, oStruMBP )
oModel:GetModel	('MBPDETAIL'):SetDescription( STR0007 )//"Recarga de cartão fidelidade"

oModel:SetActivate ({|oModel| LaFunhAct(oModel)})

Return oModel 

        

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ViewDef   ³ Autor ³ Leandro Nogueira	    ³ Data ³ 22/11/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³MVC - Camada de visualização de dados					 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ExpO1:=ViewDef()			 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 		 													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1 = oModel											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³LOJA701/FRTA271										      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oStruMBP 		:= FWFormStruct( 2, 'MBP' )
Local oModel   		:= FWLoadModel( 'LOJXFUNH' )
Local nOperation	:= oModel:GetOperation()
Local oView         


// Remove campos da estrutura
oStruMBP:RemoveField( 'MBP_ITEM' ) 
oStruMBP:RemoveField( 'MBP_DATA' ) 
oStruMBP:RemoveField( 'MBP_SALDO' ) 

// Adiciona Consulta Padrão (F3) na estrutura do campo "MBP_NUMCAR"
oStruMBP:SetProperty( 'MBP_NUMCAR', MVC_VIEW_LOOKUP, 'MBO')

// Cria o objeto de View
oView := FWFormView():New()

oView:SetModel( oModel )

//Adiciona no View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_MBPDETAIL', oStruMBP, 'MBPDETAIL' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR'	, 100)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView		( 'VIEW_MBPDETAIL'	, 'SUPERIOR' )
oView:EnableTitleView	('VIEW_MBPDETAIL'	,STR0008) //"Dados da Recarga"

Return oView 



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³LaFunhAct ³ Autor ³ Leandro Nogueira	    ³ Data ³ 17/01/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Bloco de ativacao/carga do modelo de dados				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ExpO1:=ViewDef(oExp1)		 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oExp1 - Modelo de dados									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1 = oModel											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³LOJA701/FRTA271										      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function LaFunhAct (oModel)

If Len(aRecSaldo) > 0
	oModel:SetValue ('MBPDETAIL','MBP_NUMCAR',LaFunhGet(1))
	oModel:SetValue ('MBPDETAIL','MBP_DTVAL',LaFunhGet(2))
	oModel:SetValue ('MBPDETAIL','MBP_VALOR',LaFunhGet(3))	
EndIf


Return (.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³LaFunhCmm ³ Autor ³ Leandro Nogueira	    ³ Data ³ 08/12/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Bloco de persistencia do modelo de dados					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³Expl1:=LaFunhCmm(oExp1 )	 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oExp1 - Objeto do modelo de dados							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lExp1 - lRet												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³LOJA701/FRTA271										      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function LaFunhCmm( oModel )
Local nOperation	:= oModel:GetOperation()   			// Tipo de operacao executada no modelo de dados.
Local cCliPad		:= Padr(GetMv("MV_CLIPAD"),TamSx3("A1_COD")[1])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso tenha algum valor no aRecSaldo, ele atualiza o valor   ³
//³pegando do campo da tela e caso não tenha ele atualiza todos³
//³os valores que possui na tela para o array.                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOperation == 3		
	If Len(aRecSaldo) > 0
		aRecSaldo [1][3] := oModel:GetValue('MBPDETAIL','MBP_VALOR')
	Else
		aADD(aRecSaldo,{oModel:GetValue('MBPDETAIL','MBP_NUMCAR'),oModel:GetValue('MBPDETAIL','MBP_DTVAL'),oModel:GetValue('MBPDETAIL','MBP_VALOR')})
	Endif
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³LaFunhGet ³ Autor ³ Leandro Nogueira	    ³ Data ³ 14/12/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna dados da recarga do cartao fidelidade informados na ³±±
±±³			 ³tela de Recarga/Inclusao de Saldo							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ExpA1:=LaFunhGet(cExp1 )	 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExp1 - Tipo do dado que sera retornado					  ³±±
±±³			 ³1 - Retornar numero do cartao					 			  ³±±
±±³			 ³2 - Retornar data de validade do saldo					  ³±±
±±³          ³3 - Retornar valor do saldo inserido no cartao			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aExp1 - aRecSaldo											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³LOJA701/FRTA271										      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function LaFunhGet (cTipoRet)

If Len(aRecSaldo) > 0
	Return aRecSaldo [1][cTipoRet]
EndIf

Return NIL	





/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³LaFunhDelS³ Autor ³ Leandro Nogueira	    ³ Data ³ 08/12/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Limpa o array com os dados da recarga do cartao fidelidade  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ExpA1:=LaFunhDelS()		 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aExp1 - aRecSaldo											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³LOJA701/FRTA271										      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function LaFunhDelS()

aRecSaldo := {}

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³LaFunhProd³ Autor ³ Leandro Nogueira	    ³ Data ³ 07/12/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validar se o produto informado na venda eh do tipo recarga  ³±±
±±³			 ³de cartao fidelidade.										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³Expl1:=LaFunhProd(cExp1)		 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExp1 - Codigo do produto informado na venda				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lExp1 - lRet												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³LOJA701/FRTA271										      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function LaFunhProd (cCodProd)

Local lRet 		:= .F.
Local cMVLJPFID	:= SuperGetMv("MV_LJPFID", ,"" )  		// Parametro com o codigo do produto tipo recarga de cartao fidelidade
Local aProdFid	:= StrToKarr(cMVLJPFID , "/")  			// Array com os produtos do parametro MV_LJPFID
Local nPosProd	:= 0									// Posicao do produto no array informado durante a venda

DEFAULT cCodProd := ""

//ÚÄÄÄÄÄÄÄÄ¿
//³SIGALOJA³
//ÀÄÄÄÄÄÄÄÄÙ
If AllTrim(cCodProd) <> ""
	nPosProd := Ascan(aProdFid,{|x| AllTrim(x)  == AllTrim(cCodProd)})

	If nPosProd > 0
		lRet:= .T.
	EndIf
EndIf


Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³LaFunhPgto³ Autor ³ Leandro Nogueira	    ³ Data ³ 20/12/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Tela que sera solicitado o numero do cartao fidelidade      ³±±
±±³			 ³como forma de pagto da venda								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³Expl1:=LaFunhPgto(oExp1,cExp2,aExp3,nExp4)				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oExp1 - Objeto que contem a tela de atendimento			  ³±±
±±³			 ³cExp2 - Numero do cartão fidelidade 						  ³±±
±±³			 ³aExp3 - Array de pagamento montado no LOJA701				  ³±±
±±³			 ³nExp4 - Valor da venda a ser pago com o cartao fidelidade	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lExp1 - lRet												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³LOJA701/FRTA271										      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function LaFunhPgto (oDlgVA,cNumCFid,aPgtosFid,nValPagFid)     

Local cNumCFidT	:= Space(TamSX3("MBO_CODBAR")[1])		// Variavel para armazenar o numero do cartão fidelidade informado na tela.
Local nOpd		:= 3 
Local nX		:= 0	
Local lRet		:= .F.	

If !Empty (cNumCFid)
	cNumCFidT:= cNumCFid                                               
Endif

DEFAULT nValPagFid := 0
DEFAULT	cNumCFid   := ""

If nModulo == 23
	DEFINE MSDIALOG oDlg TITLE STR0009 FROM 13,21 TO 17,110 OF GetWndDefault() //"Cartão fidelidade"
Else
	DEFINE MSDIALOG oDlg TITLE STR0009 FROM 13,21 TO 17,110 OF oDlgVA //"Cartão fidelidade"
Endif
	@ .074,.1 TO 1.8,44
	@ 06,12  SAY	STR0010   	SIZE 135,10 OF oDlg PIXEL  //"Informe o número do cartão fidelidade :"
	@ 06,130 MSGET	cNumCFidT	SIZE 150,10 OF oDlg PIXEL PICTURE PesqPict("MBO","MBO_CODBAR") 

	DEFINE SBUTTON FROM 06,290 TYPE  1 PIXEL ACTION ( nOpd:=1,oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON FROM 06,320 TYPE  2 PIXEL ACTION ( nOpd:=3,oDlg:End()) ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTERED                                                                                           
                                                                                                                              
	If nOpd=1	                                                                                                                
		cNumCFid := cNumCFidT		                                                                                             
		If nModulo <> 23                                                                                                              
			For nX:= 1 To Len(aPgtosFid)                                                                                             
				If AllTrim(aPgtosFid [nX][3]) == "FID"		            	                                                            
		        	If !Ca280Exec("CA280CART",cNumCFid)	    	        	                                                            
		        		lRet := .F.				                                                                                      
		        	Else
		        		lRet := Ca280Exec("Ca280CSld",cNumCFid,,aPgtosFid [nX][2])	
		        	Endif
		        	
				EndIf
			Next	 
		Else
			If !Ca280Exec("CA280CART",cNumCFid)        		
        		lRet := .F.				
        	Else
        		lRet := Ca280Exec("Ca280CSld",cNumCFid,,nValPagFid)	  	    		
        	Endif	
		Endif	
			
	Else				
		lRet := .F.
	Endif

Return lRet


//--------------------------------------------------------
/*/{Protheus.doc} 
Funcao principal referente a otimizacao de tabela
@param   nIntervalo	intervalo minimo de dias entre cada otimizacao de tabelas
@author  Vendas & CRM
@version P11.5
@since   23/05/2012
/*/
//--------------------------------------------------------
Function LjLimpaTb( nIntervalo )

	Local aTabelas 	:= {}		//[1] - tabela / [2] - filtro para delecao / [3] - quantidade de registros a serem deletados
	Local lValidado	:= .T.		// indica se todas as condicoes para execucao da rotina foram validadas
	Local lRetPack	:= .F.		// indica se houve a execucao do Pack em todas as tabelas
	Local cPath		:= ""		// caminho do arquivo LJLIMPTB.Ini
	Local lRetIni	:= .T.		// retorno da operacao do arquivo .ini
	
	Default nIntervalo 	:= 0	//intervalo de dias entre cada execucao - usado somente via FRTA020/LOJA1115

	//--------------------------------------------------------
	//Executa todas as validacoes antes de otimizar as tabelas
	//--------------------------------------------------------
	lValidado := LjValida(nIntervalo)

	If lValidado
		//retorna as tabelas e seus respectivos filtros para que sejam otimizadas
		aTabelas := LjRetTbl()

		//executa a funcao que realiza a exclusao logica e fisica das tabelas
		If !IsBlind()
			lRetPack := LjGUIBar( aTabelas )
		Else
			lRetPack := LjDeleteTb( aTabelas )
		EndIf
		
		If !lRetPack
			MsgAlert(STR0013) //"Operação cancelada ou ocorreu um problema ao otimizar uma das tabelas"
		EndIf
	EndIf

	//------------------------------------
	//Atualizacao do arquivo LJLIMPATB.ini
	//------------------------------------	
	//obtemos o caminho do arquivo
	cPath := LjGetPath()

	If !lValidado		
		//atualizamos somente a primeira linha: VERIFICACAO
		lRetIni := LjOpArqIni( 2, cPath, ARQUIVO, SECAO, DT_VER, DtoC(DDATABASE) )
	ElseIf lValidado .AND. lRetPack
		//se as exclusoes foram bem sucedidas, atualizamos ambas as linhas: VERIFICACAO e EXECUCAO
		lRetIni := LjOpArqIni( 2, cPath, ARQUIVO, SECAO, DT_VER, DtoC(DDATABASE) )
		lRetIni := LjOpArqIni( 2, cPath, ARQUIVO, SECAO, DT_EXE, DtoC(DDATABASE) )
		
		MsgInfo(STR0014) //"Processo Finalizado"
	EndIf
	
	If !lRetIni
		conout( STR0034 + cPath + ARQUIVO)	//"Erro ao atualizar o arquivo "
	EndIf

Return Nil


//--------------------------------------------------------------------------------------------
/*/{Protheus.doc} 
Funcao responsavel em excluir os registros logicamente
@param	aTabelas	vetor com a lista de tabelas, filtros e qtd de registros a serem excluidas
@param	lEnd	indica se o botao Cancelar foi pressionado
@author  Vendas & CRM
@version P11.5
@since   23/05/2012
@return  lRet	indica se os registros foram excluidos com sucesso
/*/
//--------------------------------------------------------------------------------------------
Static Function LJDELETETB( aTabelas, lEnd)

	Local nRegDel	:= 0	//quantidade de registros deletados
	Local nI		:= 0	//contador do For
	Local lRet		:= .T.	//retorno da funcao, indica o pack foi executado com exito
	
	Default aTabelas:= {}
	Default lEnd	:= .F.	//indica se o usuario clicou no botao Cancelar
	
	BEGIN SEQUENCE

	//setamos o valor da REGUA PRINCIPAL
	oProcess:SetRegua1( Len(aTabelas) )

	For nI := 1 to Len(aTabelas)

		//incrementamos o valor da regua principal
		oProcess:IncRegua1( STR0015 + aTabelas[nI][1] )	//"Otimizando Tabela - "

		//abre a tabela,seta um indice e aplica o filtro
		LjOpenTb( aTabelas[nI] )		

		nRegDel := 0

		//se a tabela for SL1, excluimos SL2 e SL4
		If aTabelas[nI][1] == "SL1"

			lRet := LjDelTbVda( aTabelas[nI], @lEnd )
			If !lRet
				BREAK
			EndIf

		Else		
			oProcess:IncRegua1( STR0015 + aTabelas[nI][1] )	//"Otimizando Tabela - "

			//setamos o valor da SUB-REGUA
			oProcess:SetRegua2( aTabelas[nI][3] + 1 )

			//incrementamos a SUB-REGUA
			oProcess:IncRegua2( STR0016 + aTabelas[nI][1] )	//"Filtrando Registros Obsoletos - "

			While &( aTabelas[nI][1] )->( !Eof() )	
				RecLock(aTabelas[nI][1], .F.)
					&( aTabelas[nI][1] )->( DbDelete() )
				MsUnlock()

				//esperamos 1/4 de segundo, para verificar se o botao Cancelar foi pressionado
				If lEnd
					BREAK
				EndIf

				nRegDel++

				&( aTabelas[nI][1] )->( DbSkip() )
				
		
				//para um maior desempenho, incrementamos a cada 100 registros				
				If nRegDel % 100 == 0
					oProcess:IncRegua2( STR0016 + aTabelas[nI][1] )	//"Filtrando Registros Obsoletos - "
				EndIf

			EndDo
			
			//se nRegDel nao alcancou nMaxRegDel, entao o registro nao foi deletado no bloco acima, nesse caso excluimos a sobra aqui
			If nRegDel > 0
				oProcess:IncRegua2( STR0017 + aTabelas[nI][1] )	//"Eliminando Registros Obsoletos - "

				lRet := LjPackTB( aTabelas[nI][1] )
				If !lRet
					BREAK
				EndIf
			EndIf

		EndIf
	Next
	
	RECOVER
		lRet := .F.

	END SEQUENCE

Return lRet


//------------------------------------------------------------------------
/*/{Protheus.doc} 
Funcao responsavel em excluir definitivamente os registros atraves do PACK
@param	cAlias	tabela a qual o PACK sera executado
@author  Vendas & CRM
@version P11.5
@since   23/05/2012
@return  lRet	indica se o PACK foi executado com sucesso
/*/
//------------------------------------------------------------------------
Function LJPACKTB( cAlias )

	Local lRet		:= .T.	//indica se o Pack foi executado
	Local cPathFile	:= ""	//path do arquivo fisico + nome do arquivo fisico + extensao - ex:"\data\SL1990.dbf"
	Local nI		:= 0	//contador
	Local aAliasAux	:= {}	//vetor com as tabelas que serao excluidas

	Default cAlias 	:= ""

	If cAlias == "SL1"
		aAliasAux := { "SL1", "SL2", "SL4" }
	Else
		aAliasAux := { cAlias }
	EndIf
		
	For nI := 1 to Len(aAliasAux)
		cPathFile := LjGetX2Arq( aAliasAux[nI] )

		//fechamos a tabela, para que ela seja aberto em modo exclusivo por DbUseArea()
		&( aAliasAux[nI] )->( DbCloseArea() )
		
		//abrimos a tabela em modo EXCLUSIVO, pois o PACK 'soh' pode ser realizado dessa forma
		dbUseArea(.T., __cRDD, IIF(__cRDD == "TOPCONN", RetSqlName(aAliasAux[nI]), cPathFile), aAliasAux[nI], .F., .F.)
		
		If NetErr()
			lRet := .F.
			MsgAlert( STR0018 + aAliasAux[nI] )		//"Não foi possivel abrir a tabela em modo exclusivo: "
		Else
			__DBPack()
			
			//Eh fechado o alias antes de abri-lo novamente
			(aAliasAux[nI])->( DbCloseArea() )

			//--------------------------------------------------------------------
			//abrimos a tabela e setamos o primeiro indice, pois senao o sistema
			// retorna o erro 'DBSeek - Work area not indexed on'
			//--------------------------------------------------------------------
			DbSelectArea( aAliasAux[nI] )
			&( aAliasAux[nI] )->( DbSetOrder(1) )			
		EndIf
	Next

Return lRet


//----------------------------------------------------------------------------------------
/*/{Protheus.doc} 
Funcao responsavel em abrir a tabela, setar o indice e aplicar o filtro
e contar os registros que serao deletados
@param	aAlias		vetor com informacoes de uma determinada tabela [1] Alias /	[2] Filtro
@param	nProcesso	indica se sera 1 - abertura de tabela ou 2 - contagem de registros
@author  Vendas & CRM
@version P11.5
@since   23/05/2012
@return  nRecCount	quantidade de registros que serao excluidos
/*/
//----------------------------------------------------------------------------------------
Static Function LJOPENTB( aAlias, nProcesso )

	Local bCondicao	:= ""		// bloco de codigo que macro executara a condicao
	Local cCondicao := ""		// condicao de filtro
	Local nRecCount	:= 0		// quantidade de registros
	Local oError				// objeto que contem a descricao do erro
	Local bError				// bloco de erro para usar com ErrorBlock

	Default aAlias		:= {}
	Default nProcesso	:= 1	// abrir a tabela
	
	//qualquer excecao ocorrida, eh tratada pela funcao LjExcecao
	bError := ErrorBlock( {|oError| LjExcecao(oError) } )

	BEGIN SEQUENCE

		DbSelectArea( aAlias[1] )
	
		//obtemos o filtro que sera aplicado na tabela
		cCondicao := aAlias[2]
		bCondicao := &( "{|| " + cCondicao + "}" )

		//se o Alias for SL1, deletamos SL1/SL2/SL4 para evitar registros orfaos
		If aAlias[1] == "SL1"
	
			SL1->( DbSetOrder(1) )	//L1_FILIAL + L1_NUM
			SL1->( DbSetFilter(bCondicao, cCondicao) )
			
			DbSelectArea("SL2")
			SL2->( DbSetOrder(1) )	//L2_FILIAL + L2_NUM
			
			DbSelectArea("SL4")
			SL4->( DbSetOrder(1) )	//L4_FILIAL + L4_NUM
			
			//verificamos se eh necessario contar os registros
			If nProcesso == 2
			
				//contamos os registros da tabela SL1 de 100 em 100 para nao degradar a performance
				DbSelectArea("SL1")
				While SL1->( !Eof() )
					SL1->( DbSkip(100) )
					nRecCount ++
				EndDo
				SL1->( DbGoTop() )
	
			EndIf
		Else
			&( aAlias[1] )->( DbSetOrder(1) )
			&( aAlias[1] )->( DbSetFilter(bCondicao, cCondicao) )
			&( aAlias[1] )->( DbGoTop() )		
			
			//contamos os registros
			If nProcesso == 2
				&( aAlias[1] )->( DbGoTop() )
				While &( aAlias[1] )->( !Eof() )
					&( aAlias[1] )->( DbSkip(100) )
					nRecCount ++
				EndDo
				&( aAlias[1] )->( DbGoTop() )
			EndIf
	
		EndIf

	RECOVER

	END SEQUENCE
	
	//a partir desse ponto, as excecoes passam a ser tratadas pelo sistema novamente
	ErrorBlock( bError )

Return nRecCount


//------------------------------------------------------------------------------------
/*/{Protheus.doc} 
Funcao responsavel em excluir logicamente as tabelas de Venda (SL1/SL2/SL4)
@param	aAlias	vetor com os dados da tabela SL1
@param	lEnd	indica se o botao Cancelar foi pressionado
@author  Vendas & CRM
@version P11.5
@since   23/05/2012
@return  lRet	indica se os registros foram excluidos com sucesso
/*/
//------------------------------------------------------------------------------------
Static Function LJDELTBVDA( aAlias, lEnd )
	Local lRet			:= .T.
	Local nRegDel		:= 0	//quantidade de registros deletados

	Default aAlias		:= {}

	Default lEnd		:= .F.
	
	//atribuimos o tamanho da SUB-REGUA
	oProcess:SetRegua2( aAlias[3] + 1 )

	//incrementamos a segunda regua
	oProcess:IncRegua2( STR0016 + aAlias[1] )	//"Filtrando Registros Obsoletos - "

	While SL1->( !Eof() )

		Begin Transaction

			//exclui os itens
			If SL2->( DbSeek(SL1->L1_FILIAL + SL1->L1_NUM) )
				While SL2->( !Eof() ) .AND. SL2->L2_FILIAL + SL2->L2_NUM = SL1->L1_FILIAL + SL1->L1_NUM
					RecLock("SL2", .F.)
						SL2->( DbDelete() )	
					MsUnlock()					
					SL2->( DbSkip() )
				EndDo
			EndIf

			//exclui os pagamentos
			If SL4->( DbSeek(SL1->L1_FILIAL + SL1->L1_NUM) )
				While SL4->( !Eof() ) .AND. SL4->L4_FILIAL + SL4->L4_NUM = SL1->L1_FILIAL + SL1->L1_NUM
					RecLock("SL4", .F.)
						SL4->( DbDelete() )
					MsUnlock()
					SL4->( DbSkip() )
				EndDo
			EndIf

			//exclui o cabecalho	
			RecLock("SL1", .F.)
				SL1->( DbDelete() )
			MsUnlock()
			
		End Transaction
		
		//esperamos 1/4 de segundo, para verificar se o botao Cancelar foi pressionado
		If lEnd
			lRet	:= .F.
			nRegDel := 0
			Exit
		EndIf

		//incrementa o contador
		nRegDel++

		SL1->( DbSkip() )
		
		//para um maior desempenho, incrementamos a cada 100 registros
		If nRegDel % 100 == 0
			oProcess:IncRegua2( STR0016 + aAlias[1] )	//"Filtrando Registros Obsoletos - "
		EndIf
	
	EndDo
	
	If nRegDel > 0		
		oProcess:IncRegua2( STR0017 + aAlias[1] )	//"Eliminando Registros Obsoletos - "
		lRet := LjPackTb( "SL1" )
	EndIf

Return lRet


//----------------------------------------------------------------
/*/{Protheus.doc} 
Funcao responsavel em validar se o intervalo de dias eh valido
@param	nIntervalo	intervalo minimo de dias entre cada otimizacao
@author  Vendas & CRM
@version P11.5
@since   23/05/2012
@return  lRet	indica se o intervalo de dias eh valido ou nao
/*/
//----------------------------------------------------------------
Static Function LjVldData(nIntervalo)

	Local lRet		:= .T.
	Local dLastExec			//data no formato Data com a mascara AAAADDMM
	Local cLastExec	:= ""	//data no formato Caracter com a mascara dd/mm/aa
	Local cPath		:= ""	//caminho do arquivo LJLIMPTB.ini
	Local nDiffDia	:= 0	//diferenca de dias entre a ultima execucao e a data do dia

	Default nIntervalo 	:= 0
	
	//obtemos o caminho do arquivo
	cPath := LjGetPath()

	//retornamos a segunda linha do arquivo LJLIMPTB.ini, que contem a data da ultima otimizacao
	cLastExec := LjOpArqIni( 1, cPath, ARQUIVO, SECAO, DT_EXE, "01/01/01" )
	dLastExec := CtoD(cLastExec)

	nDiffDia := DDATABASE - dLastExec

	//----------------------------------------------------------------------------
	//se a diferenca de dias entre a data atual e a data da ultima limpeza for 
	//menor que o valor do parametro MV_DIAOT, nao executamos a rotina de limpeza
	//----------------------------------------------------------------------------
	If nDiffDia < nIntervalo
		lRet := .F.
	EndIf

Return lRet


//-------------------------------------------------------------------------
/*/{Protheus.doc} 
Funcao responsavel em validar se o driver do banco de dados local eh valido
@author  Vendas & CRM
@version P11.5
@since   23/05/2012
@return  lRet indica se o driver eh valido para a otimizacao de tabelas
/*/
//-------------------------------------------------------------------------
Static Function LJVLDDRV()

	Local lRet			:= .T.	//retorno da funcao
	Local cDriver		:= ""	//driver de conexao com o banco de dados

	//obtemos o driver de conexao do banco de dados
	cDriver := AllTrim( __LOCALDRIVER )

	//a rotina nao deve ser executada em ambiente TopConnect
	If cDriver == "TOPCONN"
		lRet := .F.
	EndIf

Return lRet


//-----------------------------------------------------------------------------
/*/{Protheus.doc} 
Funcao responsavel em retornar o caminho e nome do arquivo da tabela
@param	cAlias	Alias da tabela que se deseja retornar o path e nome do arquivo
@author  Vendas & CRM
@version P11.5
@since   23/05/2012
@return  cPathFile	caminho e nome do arquivo
/*/
//-----------------------------------------------------------------------------
Static Function LjGetX2Arq(cAlias) 

	Local cPathFile	:= ""			//caminho + nome do arquivo fisico da tabela
	Local cExt		:= ""			//extensao do banco de dados local
	Local aArea		:= GetArea()
	
	Default cAlias	:= ""
	
	//obtemos a extensao do banco de dados local
	cExt := GetSrvProfString( "localdbextension", ".dbf" )
	
	//obtemos o nome do arquivo, atraves da tabela SX2
	DbSelectArea("SX2")
	If SX2->( DbSeek(cAlias) )
		cPathFile := RetSX2Arq(cAlias,.T.) + cExt
	EndIf
	
RestArea( aArea )

Return cPathFile


//------------------------------------------------------------------
/*/{Protheus.doc} 
Funcao responsavel em retornar a localizacao do arquivo LJLIMPTP.ini
@author  Vendas & CRM
@version P11.5
@since   23/05/2012
@return  cPath	caminho absoluto do arquivo LJLIMPTB.ini
/*/
//------------------------------------------------------------------
Static Function LjGetPath()
	Local cPath		:= ""	//caminho do arquivo LJLIMPTB.ini
	
	//obtemos o RootPath do arquivo appserver.ini
	cPath := GetSrvProfString ("RootPath", "\undefined" )

	cPath += "\autocom\pack" + cEmpAnt + cFilAnt + "\"

Return cPath


//------------------------------------------------------------------
/*/{Protheus.doc} 
Funcao responsavel em executar todas as validacoes, 
antes que a otimizacao de tabelas seja executada
@param	nIntervalo	intervalo minimo de dias entre cada otimizacao
@author  Vendas & CRM
@version P11.5
@since   23/05/2012
@return  lRet	indica se a otimizacao de tabelas pode ser executada
/*/
//------------------------------------------------------------------
Static Function LjValida(nIntervalo)
	Local lRet := .T.
	
	Default nIntervalo := 0

	//executa bloco de validacao
	BEGIN SEQUENCE

		//validamos o driver de conexao
		If !LjVldDrv()
			MsgAlert( STR0019 )	//"Nao é permitido executar a rotina de otimização de tabelas em ambientes que utilizam o driver TOPCONN"
			BREAK
		EndIf
		
		//verifica se a diferenca entre a ultima otimizaca e a data do dia eh igual ou maior que o intervao minimo
		If !LjVldData( nIntervalo )
			conout( STR0020 )	//"O intervalo de dias entre a ultima limpeza e a data atual, e menor que o valor do parametro MV_LJDIAOT"
			BREAK
		EndIf
		
		//verifica se o usuario vai ou nao executar a otimizacao de tabela
		If !LjVldMsg()
			BREAK
		EndIf

	RECOVER
		lRet := .F.

	END SEQUENCE

Return lRet


//---------------------------------------------------------------------------
/*/{Protheus.doc} 
Funcao responsavel em verificar se o usuario vai ou nao executar a otimizacao
antes que a otimizacao de tabelas seja executada
@param	nIntervalo	intervalo minimo de dias entre cada otimizacao
@author  Vendas & CRM
@version P11.5
@since   23/05/2012
@return  lRet	indica se o usuario aceitou ou nao a otimizacao de tabelas
/*/
//---------------------------------------------------------------------------
Static Function LjVldMsg()
	Local lRet := .F.

	MsgAlert(	STR0021 + CRLF + ;	//"Otimização de Tabelas"
				STR0022 + CRLF + ;	//"A otimização de Tabelas visa a melhoria de performance do banco de dados local."
				STR0023	+ ;			//"Sua execução pode demorar alguns minutos, dependendo da quantidade de registros. "
				STR0024 + CRLF + ;	//"Nesse período, o caixa não poderá ser utilizado."
				STR0025 + CRLF + CRLF + ;	//"Para executá-la, clique em SIM na próxima pergunta."
				STR0026	)	//"NOTA: Se você estiver no ambiente referente a RETAGUARDA, clique em NÃO."

	If MsgYesNo( STR0027 )	//"Deseja executar a rotina de Otimização de Tabelas?"
		lRet := .T.
	EndIf

Return lRet


//-----------------------------------------------------------------------------------
/*/{Protheus.doc} 
Funcao responsavel em ler/alterar o arquivo um arquivo .ini
@param	nOperacao	indica a operaca que sera feita no arquivo .ini
@author  Vendas & CRM
@version P11.5
@since   23/05/2012
@return  uRet	se a operacao foi leitura, retorna o valor da chave de um arquivo .ini
				se a operacao foi gravacao, retorna se o arquivo foi atualizado ou nao
/*/
//------------------------------------------------------------------------------------
Static Function	LjOpArqIni( nOperacao, cPath, cArquivo, cSecao, cChave, cValor )

	Local uRet					//se operacao for ATUALIZACAO, retorna valor logico(L), senao valor CARACTER(C)
	Local nRetDir	:= 0		//indica o codigo de retorno para criacao da pasta
	Local lDirOk	:= .T.		//indica se o diretorio foi criado com exito

	Default nOperacao	:= 1 
	Default cPath		:= ""
	Default cArquivo	:= ""
	Default cSecao		:= ""
	Default cChave		:= ""
	Default cValor		:= ""

	//operacao de leitura do arquivo .ini
	If nOperacao == 1
		uRet := GetPvProfString( cSecao, cChave, cValor, (cPath + cArquivo) )

	//atualizacao do arquivo .ini
	ElseIf nOperacao == 2
		
		//criamos o diretorio se ele nao existir		
		If !ExistDir(cPath)
			nRetDir := MakeDir(cPath)
		
			If nRetDir <> 0
				MsgAlert( STR0028 + cPath )		//"Não foi possível criar o diretório "
				lDirOk := .F.
			EndIf
		EndIf

		//se a pasta ja existe ou foi criada, atualizamos o arquivo .ini
		If lDirOk
			uRet := WritePProString( cSecao, cChave, cValor, (cPath + cArquivo) )
		EndIf

	EndIf

Return uRet


//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} 
Funcao responsavel em verificar se a consulta a retaguarda ja foi realizada no dia corrente
@author  Vendas & CRM
@version P11.5
@since   23/05/2012
@return  lRet	Indica se a consulta ja foi realizada ou nao
@obs	se retornar False, a otimizacao de tabelas pode proceder na funcao chamadora
/*/
//-----------------------------------------------------------------------------------------
Function LjCnsRetHj()
	Local lRet		:= .F.	//retorno da funcao
	Local cPath		:= ""	//caminho do arquivo LJLIMPTB.ini
	Local cDtUltVer	:= ""	//data da ultima verificacao no tipo Caracter
	Local dDtUltVer			//data da ultima verificacao no tipo Data

	//obtemos o caminho do arquivo
	cPath := LjGetPath()

	//retornamos o valor da chave dt_verificacao do arquivo LJLIMPTB.INI
	cDtUltVer := LjOpArqIni( 1, cPath, ARQUIVO, SECAO, DT_VER, "01/01/01" )
	dDtUltVer := CtoD(cDtUltVer)

	//somente executamos a rotina uma vez por dia, para que nao haja bombardeamento de consultas RPC na retaguarda
	If dDtUltVer == DDATABASE
		lRet := .T.
	EndIf

Return lRet


//------------------------------------------------------------------------
/*/{Protheus.doc} 
Funcao responsavel em montar a lista de tabelas e seus respectivos filtros
@author  Vendas & CRM
@version P11.5
@since   23/05/2012
@return  aRetTabela	Indica se a consulta ja foi realizada ou nao
@obs	se retornar False, a otimizacao de tabelas pode proceder na funcao
/*/
//------------------------------------------------------------------------
Static Function LjRetTbl()

	Local cCondicao	:= ""	//condicao que sera aplicada a tabela para se obter os registros obsoletos
	Local nI		:= 0	//contador
	Local nRecCount := 0	//quantidade de registros obsoletos
	Local aRetTabela:= {}	//lista com as tabelas que serao otimizadas
	Local aAuxTabela:= {}	//lista auxiliar de tabelas que serao validadas antes que sejam otimizadas
	Local aTabelasPE:= {}	//tabelas retornadas do ponto de entrada LJ7075
	Local lLJ7075	:= ExistBlock( "LJ7075" )	//indica se o ponto de entrada LJ7075 existe
	Local dDtLimite := DDATABASE - 30

	//--------------------------
	//Tabelas a serem otimizadas
	//--------------------------
	cCondicao := "DTOS( L1_EMISSAO ) <= '" + DTOS( dDtLimite ) + "' .AND. L1_SITUA == 'TX'"
	Aadd( aAuxTabela,	{"SL1",	cCondicao} )
	
	cCondicao := "DTOS( E5_DATA ) <= '" + DTOS( dDtLimite ) + "' .AND. E5_SITUA == 'TX'"
	Aadd( aAuxTabela,	{"SE5", cCondicao} )

	cCondicao := "DTOS( FI_DTMOVTO ) <= '" + DTOS( dDtLimite ) + "' .AND. FI_SITUA == 'TX'"
	Aadd( aAuxTabela,	{"SFI", cCondicao} )

	//Tabelas usadas em modo Offline
	cCondicao := "DTOS(MD6_DATA) <= '" + DTOS( dDtLimite ) + "' .AND. MD6_STATUS == '2'"
	Aadd( aAuxTabela,	{"MD6", cCondicao} )

	cCondicao := "MD7_STATUS == '2'"
	Aadd( aAuxTabela,	{"MD7", cCondicao} )
	
	cCondicao := "DTOS( CTOD(MD8_DATA) ) <= '" + DTOS( dDtLimite ) + "' .AND. MD8_STATUS == '2'"
	Aadd( aAuxTabela,	{"MD8", cCondicao} )

	//-----------------------
	//Ponto de Entrada LJ7075
	//-----------------------
	If lLJ7075
		aTabelasPE := ExecBlock("LJ7075", .F., .F.)
		If !Empty( aTabelasPE )
			For nI := 1 to Len(aTabelasPE)
				Aadd( aAuxTabela, aTabelasPE[nI] )
			Next
		EndIf
	EndIf

	For nI := 1 to Len(aAuxTabela)
	
		If !AliasIndic( aAuxTabela[nI][1] )
			Loop
		EndIf

		//contamos a quantidade de de registros obsoletos
		nRecCount := LJOPENTB( aAuxTabela[nI], 2 )

		//se ha registros a deletar, fazemos o backup da tabela
		If nRecCount > 0
			//se nao conseguir fazer o backup do arquivo, nao otimizamos a tabela
			If !LjFileBkp( aAuxTabela[nI][1] )
				Loop
			EndIf			

			//adiciona a quantidade de registros que serao deletados no registro
			Aadd( aAuxTabela[nI], nRecCount )	
			
			//adiciona os dados da tabela ao array que sera retornado
			Aadd( aRetTabela, aAuxTabela[nI] )
		EndIf
	Next

Return aRetTabela


//------------------------------------------------------------------------
/*/{Protheus.doc} 
Funcao responsavel em criar o objeto referente a barra de progressao dupla
@param	 aTabelas	lista com as tabelas a serem otimizadas
@author  Vendas & CRM
@version P11.5
@since   23/05/2012
@return  lRet	indica se houve algum erro durante a otimizacao de tabelas
/*/
//------------------------------------------------------------------------
Static Function LjGUIBar(aTabelas)

	Local lRet	:= .T.
	Local lEnd	:= .F.	//Indica se o botao Cancelar foi pressionado
	
	Default aTabelas := {}
	
	//"Otimização de Tabelas"	//"Analisando Registros"
	oProcess := MsNewProcess():New({|lEnd| lRet := LjDeleteTb(aTabelas, @lEnd) }, STR0029, STR0030, .T.)
	oProcess:Activate()
	
Return lRet


//-------------------------------------------------------------------------------
/*/{Protheus.doc} 
Funcao responsavel em criar/apagar um arquivo de backup da tabela a ser otimizada
@param	 cAlias	tabela a ser feito o backup
@author  Vendas & CRM
@version P11.5
@since   23/05/2012
@return  lRet	indica se o backup foi realizado
/*/
//-------------------------------------------------------------------------------
Static Function LjFileBkp( cAlias )

	Local cFile		:= ""	//nome do arquivo + extensao que sera feito o backup
	Local cFileBkp	:= ""	//nome do arquivo de backup
	Local lRet		:= .T.
	
	Default cAlias 	:= ""
	
	//obtemos o path e nome do arquivo
	cFile := LjGetX2Arq( cAlias )
	
	//retiramos a extensao do database local e inserimos .bkp
	cFileBkp := SubStr( cFile, 1, Len(cFile)-3 ) + "bkp"
	
	//se o arquivo ja existe, excluimos o arquivo de backup
	If File(cFileBkp)
		//apagamos o arquivo de backup
		If !MsErase( cFileBkp )
			lRet := .F.
			conout( STR0031 + cFileBkp )	//"Erro ao deletar o arquivo de backup "
		EndIf
	EndIf
	
	If lRet
		//criamos o arquivo de backup
		If !MsCopyFile( cFile, cFileBkp )
			conout( STR0032 + cFile )		//"Erro ao criar o backup do arquivo "
			lRet := .F.
		EndIf
	EndIf

Return lRet


//----------------------------------------------------------
/*/{Protheus.doc} 
Funcao responsavel em tratar excecoes em tempo de execucao
@param	 oError	Objeto contendo todas as informacoes do erro
@author  Vendas & CRM
@version P11.5
@since   23/05/2012
@obs	 Usada somente na funcao LjOpenTB
/*/
//----------------------------------------------------------
Static Function LjExcecao( oError )

	Local cError := ""	//descricao do erro
	
	cError := oError:Description
 	
 	MsgAlert( STR0033 + cError )	//"ERRO: "
	BREAK
	
Return Nil
