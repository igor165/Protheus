#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATA206.CH"
#INCLUDE "FWMVCDEF.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATA206  ³ Autor ³ Rodrigo T. Silva      ³ Data ³29/10/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³DeSGNi‡…o ³ Programa de liberacao de estruturas.                		  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void MATA206(void)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MATA206()
Local ca206User := RetCodUsr()
Local cFiltraSGN
local lFiltroUs1:=.T.
Local aCores :={{'GN_STATUS== "01"', 'BR_AMARELO' },; //Aguradando outros niveis
	{ 'GN_STATUS== "02"', 'BR_BRANCO' },;   //Aguardando liberacao
	{ 'GN_STATUS== "03"', 'ENABLE' },;   //Liberado
	{ 'GN_STATUS== "04"', 'DISABLE' },;    //Rejeitado
	{ 'GN_STATUS== "05"', 'BR_AZUL'},;   //Aprovado por outro usuario
	{ 'GN_STATUS== "06"', 'BR_LARANJA'},;	   //Rejeitado por outro usuario
	{ 'GN_STATUS== "07"', 'BR_CINZA'},;  //Bloqueado
	{ 'GN_STATUS== "08"', 'BR_PRETO'}}   //Bloqueado por outro usuario

PRIVATE aIndexSGN	:= {}
PRIVATE bFilSGNBrw := {|| Nil}
PRIVATE cXFiltraSGN
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aRotina := MenuDef()
PRIVATE cCadastro := OemToAnsi(STR0001) // "Liberacao de Engenharia"
Default lAutoMacao := .F.

If Pergunte("MTA097",.T.)	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Controle de Aprovacao : GN_STATUS -->                ³
	//³ 01 - Bloqueado p/ sistema (aguardando liberacao) 	 ³
	//³ 02 - Bloqueado (aguradando outros niveis) 			 ³
	//³ 03 - Liberado pelo usuario         					 ³
	//³ 04 - Bloqueado (aguardando outros niveis)            ³
	//³ 05 - Liberado por outro usuario		             	 ³
	//³ 06 - Rejeitado por outro usuario	                 ³
	//³ 07 - Bloqueado pelo usuario	                 		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicaliza a funcao FilBrowse para filtrar a mBrowse          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SGN")
	dbSetOrder(1)
                             
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de Entrada: MT206LBF   -                                |
	//³ Este ponto de entrada tem como finalidade indicar se a filial ³
	//| sera utilizada na filtragem dos campos para a MBrowse 		  |
	//| .T. = Considera a filial no filtro					 		  |
	//| .F. = NAO considera a filial no filtro				 		  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("MT206LBF")
		If ValType(lFiltroUs1 := ExecBlock( "MT206LBF", .F., .F. )) == "L"     
		    if !lFiltroUs1
	            cFiltraSGN  := 'GN_USER=="'+ca206User
  			    Endif
  			Endif    
 		EndIf
 		
 		if cFiltraSGN==nil
 		    cFiltraSGN  := 'GN_FILIAL=="'+xFilial("SGN")+'"'+'.And.GN_USER=="'+ca206User
   	    endIf		
   	    
   		Do Case
		Case mv_par01 == 1
			cFiltraSGN += '".And.GN_STATUS=="02"'
		Case mv_par01 == 2
			cFiltraSGN += '".And.(GN_STATUS=="03".OR.GN_STATUS=="05")'
		Case mv_par01 == 3
			cFiltraSGN += '"'
		OtherWise
			cFiltraSGN += '".And.(GN_STATUS=="01".OR.GN_STATUS=="04")'
	EndCase
				
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define ponto para o filtro de usuario                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("MT206FIL" )
		If ValType( cFiltroUs := ExecBlock( "MT206FIL", .F., .F. ) ) == "C"
			cFiltraSGN += " .And. " + cFiltroUs
		EndIf
	EndIf		
	
	bFilSGNBrw 	:= {|| FilBrowse("SGN",@aIndexSGN,@cFiltraSGN) }
	Eval(bFilSGNBrw)	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcao de BROWSE                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF !lAutoMacao
		mBrowse(6, 1,22,75,"SGN",,,,,,aCores)
	ENDIF 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza o uso da funcao FilBrowse e retorna os indices padroes.       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	EndFilBrw("SGN",aIndexSGN)

EndIf
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A206Visual³ Autor ³ GDP Materiais 	    ³ Data ³30/10/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³DeSGNi‡…o ³ Programa de visualiza‡ao da pre-estrutura				  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A206Visual(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A206Visual(cAlias,nReg,nOpcx)            
Private lRestEst := SuperGetMv("MV_RESTEST",.F.,.F.)
Private ldbTree  := .F.
Private nIndex   := 1
Private cInd5    := ''

dbSelectArea("SGG")
dbSetOrder(1)
If MsSeek(xFilial("SGG")+SGN->GN_NUM)
	FWExecView(STR0044, "PCPA135", MODEL_OPERATION_VIEW,,,,,,,,, ) //STR0044 - VISUALIZAR
Else
	Aviso("A206BLQ",STR0043,{STR0003}) //Para este registro já foi gerado estrutura, consulte esta rotina no cadastro de estruturas.
EndIf
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A206Libera³ Autor ³Rodrigo T. Silva       ³ Data ³04/11/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³DeSGNi‡…o ³ Programa de Liberacao da pre-estrutura.		              ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void A206Libera(ExpC1,ExpN1,ExpN2)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A206Libera(cAlias,nReg,nOpcx)
Local aArea			:= GetArea()
Local aCposObrig	:= {}
Local cObs 			:= IIF(!Empty(SGN->GN_OBS),SGN->GN_OBS,CriaVar("GN_OBS"))
Local ca206User 	:= RetCodUsr()
Local cName     	:= ""
Local dRefer 		:= dDataBase
Local lLibOk    	:= .F.                                               
Local lContinua 	:= .T.
Local lOGpaAprv 	:= SuperGetMv("MV_OGPAPRV",.F.,.F.)
Local nOpc      	:= 2
Local oDlg
Local oDataRef
Local oChkNivel
Local aSize 		:= {0,0}
Local lChkAprov 	:= .F.
Local cNumDocto		:= ""
Local cTitulo		:= ""

Default lAutoMacao  := .F.

aCposObrig:= {"GG_COD","GG_COMP","GG_NIV"} 
If ExistBlock("MT206LIB")
	ExecBlock("MT206LIB",.F.,.F.)
EndIf

If ExistBlock("MT206LOK")
	lContinua := ExecBlock("MT206LOK",.F.,.F.)
	If ValType(lContinua) # 'L'
		lContinua := .T.
	EndIf
EndIf

If lContinua .And. !Empty(SGN->GN_DATALIB) .And. SGN->GN_STATUS$"03#05"
	Aviso("A206BLQ",STR0002,{STR0003}) //Esse registro ja foi liberado anteriormente. Somente os registros que estao aguardando liberacao (destacado em vermelho no Browse) poderao ser liberados
	lContinua := .F.
ElseIf lContinua .And. SGN->GN_STATUS$"01"
	Aviso("A206BLQ",STR0004,{STR0003}) //Esta operação não poderá ser realizada pois este registro se encontra bloqueado pelo sistema (aguardando outros niveis)"
	lContinua := .F.
ElseIf lContinua .And. SGN->GN_STATUS$"04#06"
	Aviso("A206BLQ",STR0005,{STR0003}) //Esta operação não poderá ser realizada pois este registro foi rejeitado pelo aprovador.
	lContinua := .F.
EndIf

If lContinua .And. lOGpaAprv
	If Eof()
		Aviso("A206NOAPRV",STR0006,{STR0003}) // "O aprovador não foi encontrado no grupo de aprovação deste documento, verifique e se necessário inclua novamente o aprovador no grupo de aprovação "
		lContinua := .F.
    EndIf
EndIf
	
If lContinua	
	If SGN->GN_TIPO == "SGG"
		cName  	  := UsrRetName(ca206User)
		cNumDocto := SGN->GN_NUM
		aSize 	  := {140,430}	    
	   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de Entrada MT206DLG permite alterar o tamanho da tela.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("MT206DLG")
	   		aMT206DLG:=ExecBlock("MT206DLG",.F.,.F.,{aSize})
	   		If Valtype(aMT206DLG)== "A"
	   		  	aSize := aClone(aMT206DLG)
			EndIf
    	EndIf
		     
		Do Case 
			Case nOpcx == 3 
				cTitulo := OemToAnsi(STR0007)  //Liberação
			Case nOpcx == 4
				cTitulo := OemToAnsi(STR0008) //Rejeição
			Case nOpcx == 5 
				cTitulo := OemToAnsi(STR0009) //Bloqueio
		EndCase
		
		DEFINE MSDIALOG oDlg FROM 000,000 TO aSize[1],aSize[2] TITLE cTitulo PIXEL  
		
		@ 001,001  TO 050,216 LABEL "" OF oDlg PIXEL	
		@ 007,006 Say OemToAnsi(STR0010) OF oDlg PIXEL SIZE 080,009  //Codigo
		@ 007,130 Say OemToAnsi(STR0011) OF oDlg PIXEL SIZE 050,009  //Emissao	
		@ 021,006 Say OemToAnsi(STR0012) OF oDlg PIXEL SIZE 080,009  //Aprovador 
		@ 021,130 Say OemToAnsi(STR0013) OF oDlg PIXEL SIZE 050,009  //Data de ref.  
		
		@ 035,006 Say OemToAnsi(STR0014) OF oDlg PIXEL SIZE 100,010  //"Observa‡äes "
		@ 007,053 MSGET SGN->GN_NUM        When .F. SIZE 060,009 OF oDlg PIXEL
		@ 007,165 MSGET SGN->GN_EMISSAO    When .F. SIZE 045,009 OF oDlg PIXEL CENTER
		@ 021,053 MSGET cName              When .F. SIZE 060,009 OF oDlg PIXEL CENTER		
		@ 021,165 MSGET oDataRef VAR dRefer When .F. SIZE 045,009 OF oDlg PIXEL	     
		@ 035,053 MSGET cObs 		SIZE 157,009 OF oDlg PIXEL
		
		@ 058,006 CHECKBOX oChkNivel VAR lChkAprov PROMPT If(nOpcX==4,STR0015,STR0016) SIZE 150,080 OF oDlg PIXEL ;oChkNivel:oFont := oDlg:oFont	 //"Rejeitar todos os níveis"#Aprovar/bloquear todos os níveis
		@ 055,135 BUTTON OemToAnsi(STR0017) SIZE 040,011 FONT oDlg:oFont ACTION (nOpc:=1,oDlg:End()) OF oDlg PIXEL		
		@ 055,176 BUTTON OemToAnsi(STR0018)  SIZE 040,011 FONT oDlg:oFont ACTION (nOpc:=2,oDlg:End()) OF oDlg PIXEL
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de Entrada MT206SGN permite a customizacao de botoes      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("MT206SGN")
			ExecBlock("MT206SGN",.F.,.F.,{@oDlg})
		EndIf    							
		ACTIVATE MSDIALOG oDlg CENTERED
	EndIf
	
	If nOpc # 2
		SGN->(dbClearFilter())
		SGN->(dbGoTo(nReg))

		If ( SGN->GN_TIPO == "SGG" )
			lLibOk := A206Lock(Substr(SGN->GN_NUM,1,Len(SGG->GG_COMP)),SGN->GN_TIPO)
		EndIf
		If lLibOk
			Begin Transaction 
				A206ApSGN(cNumDocto,SGN->GN_TIPO,ca206User,cObs,dRefer,lChkAprov,If(nOpcX==4,3,If(nOpcX==3,4,6)))
			End Transaction
		Else
			Help(" ",1,"A206LOCK")
		EndIf
	EndIf
	dbSelectArea("SGN")
	dbSetOrder(1)
	
	IF !lAutoMacao
		SGN->(Eval(bFilSGNBrw))
	ENDIF
EndIf
RestArea(aArea)
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A206VldPsw³ Autor ³ Edson Maricate        ³ Data ³15.10.1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³DeSGNi‡…o ³ Valida a senha digitada pelo usuario.                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpL1 := A206VldPsw(ExpC1,ExpC2)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Usuario                                  ³±±
±±³          ³ ExpC2 = Senha digitada                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A206VldPsw(cUser,cPass)
Local lRet := .T.
PswOrder(1)
PswSeek(cUser)

If !PswName(cPass)
	Help(" ",1,"A206SENHA") 
	lRet := .F.
EndIf
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Ma206Pesq ³ Autor ³Eduardo Riera          ³ Data ³23.01.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³DeSGNi‡…o ³Tratamento do Filtro na Pesquisa                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.	                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ma206Pesq()

AxPesqui()

Eval(bFilSGNBrw)

Return(.T.)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A206Legend³ Autor ³ Aline Correa do Vale  ³ Data ³ 07.10.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³DeSGNi‡…o ³Cria uma janela contendo a legenda da mBrowse               ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATA206                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A206Legend()  	
BrwLegenda(cCadastro,STR0042,{ ; //Legenda
	{"BR_BRANCO", STR0019},; //Aguardando liberação
	{"ENABLE", STR0020},; //Liberado
	{"DISABLE", STR0021},; //Rejeitado
	{"BR_CINZA", STR0022},; //Bloqueado		
	{"BR_AMARELO", STR0023},; //Aguardando outros níveis	
	{"BR_AZUL", STR0024},; //Liberado por outro usuário	
	{"BR_LARANJA", STR0025},; //Rejeitado por outro usuário	
	{"BR_PRETO", STR0026}})  //Bloqueado por outro usuário
	
Return(.T.)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A206Lock ³ Autor ³ Nereu Humberto Junior ³ Data ³ 01.09.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³DeSGNi‡…o ³ Verifica se a pre-estrutura nao esta com lock           	  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpL1 := A206Lock(ExpC1,ExpC2)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Documento                                ³±±
±±³          ³ ExpC2 = Tipo do Documento                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATA206                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A206Lock(cNumero,cTipo)
Local aArea    := {}
Local lRet     := .F.

If cTipo == "SGG"
	aArea := SGG->(GetArea())
	dbSelectArea("SGG")
	dbSetOrder(1)
	If MsSeek(xFilial("SGG")+cNumero)
		While !Eof() .And. SGG->GG_FILIAL+SGG->GG_COD==xFilial("SGG")+cNumero
			If RecLock("SGG")
				lRet := .T.
			Else
				lRet := .F.
				Exit
			Endif
			dbSkip()
		EndDo
	EndIf
Endif
RestArea(aArea)

Return(lRet)
                    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A206Ausente³Autor  ³Alexandre Inacio Lemes ³Data ³27/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³DeSGNi‡…o ³Acessa as liberacoes dos Aprovadores que possuem o usuario  ³±±
±±³          ³Logado cadastrado como Superior no grupo de aprovadores. 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                              	                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A206Ausente()
Local aArea		 := GetArea()
Local aCpos     := {"GN_NUM","GN_TIPO","GN_USER","GN_USERLIB","GN_STATUS","GN_EMISSAO"}
Local aHeadCpos := {}
Local aHeadSize := {}
Local aArraySGN := {}
Local aCampos   := {}
Local aCombo    := {}
Local cAliasSGN := "SGN"
Local cAprov    := ""
Local cUserName := ""   
Local cUsrApvSup:= "" 
Local cUser     := RetCodUsr()
Local nX        := 0
Local nOpc      := 0
Local nOk       := 0
Local oDlg
Local oQual
Local aCampo
Default lAutoMacao := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza o uso da funcao FilBrowse e retorna os indices padroes.       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	

IF !lAutoMacao
	EndFilBrw("SGN",aIndexSGN)
ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Header com os titulos do TWBrowse             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(2)
For nx := 1 to Len(aCpos)
	dbSetOrder(2)
	If MsSeek(aCpos[nx])
		AADD(aHeadCpos,AllTrim(X3Titulo()))
		
		aCampo := tamSX3(aCpos[nx])
		
		AADD(aHeadSize,CalcFieldSize(aCampo[3],aCampo[1],aCampo[2],X3PICTURE(aCpos[nx]),X3Titulo()))
		AADD(aCampos,{GetSx3Cache(aCpos[nx], 'X3_CAMPO'), aCampo[3], GetSx3Cache(aCpos[nx], 'X3_CONTEXT'), X3PICTURE(aCpos[nx])})
	EndIf
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Apartir do codigo do usuario do sistema, obtem o codigo|
//³da cadeia de aprovadores superiores e os aprovadores   ³
//³ausentes												  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SGM")
dbSetOrder(5)
dbSeek(xFilial("SGM")+cUser)       
       
While (!Eof() .And. SGM->GM_FILIAL == xFilial("SGM") .AND. SGM->GM_SUPER == cUser)
	If SGM->GM_SUPER == cUser 
   		AADD(aCombo,SGM->GM_USER+" - "+SGM->GM_NOME)
 	EndIf
  	SGM->(dbSkip())
EndDo                        
               
cUsrApvSup := ""

IF !lAutoMacao
	If Len(aCombo) > 0	             	
		A206Aprov(cAliasSGN,Substr(aCombo[1],1,6),@aArraySGN,aCampos,aCombo)	
		
		DEFINE MSDIALOG oDlg FROM 000,000 TO 400,780 TITLE STR0027 PIXEL // "Transferencia por Ausencia Temporaria de Aprovadores"
		@ 001,001  TO 050,425 LABEL "" OF oDlg PIXEL
		
		@ 012,006 Say STR0028 OF oDlg PIXEL SIZE 080,009 // "Aprovador Ausente"
		@ 012,058 MSCOMBOBOX cAprov ITEMS aCombo SIZE 250,090 WHEN .T. VALID A206Aprov(cAliasSGN,cAprov,@aArraySGN,aCampos,aCombo,oQual) OF oDlg PIXEL
		
		@ 030,006 Say STR0029 OF oDlg PIXEL SIZE 080,009 // "Aprovador Superior" 
		@ 030,058 MSGET cUserName : = (trim(A206UsuSup(cAprov))+If(Len(aCombo)>1,"   "+STR0032,"")) When .F. SIZE 250,009 OF oDlg PIXEL   
		
		oQual:= TWBrowse():New( 051,001,389,133,,aHeadCpos,aHeadSize,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		oQual:SetArray(aArraySGN)
		oQual:bLine := { || aArraySGN[oQual:nAT] }
		
		@ 187,299 BUTTON STR0017 SIZE 040,011 FONT oDlg:oFont ACTION (nOpc:=1,oDlg:End())  OF oDlg PIXEL // "Confirmar "
		@ 187,340 BUTTON STR0018 SIZE 040,011 FONT oDlg:oFont ACTION (nOpc:=2,oDlg:End())  OF oDlg PIXEL // "Cancelar  "
		
		ACTIVATE MSDIALOG oDlg CENTERED

		If nOpc == 1 
			cUsrApvSup:=Substr(cUserName,1,6)

			If !Empty(aArraySGN[1][1])
		
				nOk := Aviso(STR0030,STR0031,{STR0018,STR0017},2) //"Atencao!"###"Ao confirmar este processo todas aprovações pendentes do aprovador serão transferidas ao aprovador superior. Confirma a Transferência ? "###"Cancelar"###"Confirma"
		
				If  nOk == 2  // Confirma a transferencia	
					For nX := 1 To Len(aArraySGN)
						dbSelectArea("SGN")                
						dbSetOrder(2)
						dbSeek(xFilial("SGN")+aArraySGN[nX][2]+aArraySGN[nX][1]+aArraySGN[nX][3])
						Begin Transaction
						MaAlcEng({SGN->GN_NUM,SGN->GN_TIPO,cUsrApvSup,,STR0033},,2) // "Transferido por Ausencia"
						End Transaction	
					Next nX		
				EndIf 
				
			Else
				Aviso("A206NOSGN",STR0034,{STR0003}) //"Não existem registros para serem transferidos"         
			EndIf        
		EndIf	
	Else
		Aviso("A206NOSUP",STR0035,{STR0003}) //"Para utilizar esta opção é necessario que exista no minimo um aprovador com um superior cadastrado"
	EndIf

	SGN->(Eval(bFilSGNBrw))
ENDIF

RestArea(aArea)	
	
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A206UsuSup ³Autor  ³Julio C.Guerato        ³Data ³11/02/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³DeSGNi‡…o ³ Retorna Dados do Usuario Superior apartir de um aprovador. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A206UsuSup(ExpC1)				   			 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Cod.do Aprovador                                   ³±±
±±³Retorno   ³ String com Codigo / Nome do Superiorr                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A206UsuSup(cAprov)
Local aAreaSGM   := SGM->( GetArea() )
Local cUsr :=""    

dbSelectArea("SGM")
dbSetOrder(4)
dbSeek(xFilial("SGM")+cAprov)
cUsr = (SGM->GM_SUPER +" - "+UsrFullName(SGM->GM_SUPER))  
RestArea( aAreaSGM) 
return (cUsr)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A206Aprov  ³Autor  ³Alexandre Inacio Lemes ³Data ³27/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³DeSGNi‡…o ³Acessa as liberacoes dos Aprovadores que possuem o usuario  ³±±
±±³          ³Logado cadastrado como Superior no cadastro de Aprovadores. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A206Aprov(ExpC1,ExpC2,ExpA1,ExpA2,ExpA3,ExpO1)			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do SGN                                       ³±±
±±³          ³ ExpC2 = cod.do aprovador                                   ³±±
±±³          ³ ExpA1 = array dos campos de SGN		                      ³±±
±±³          ³ ExpA2 = array dos campos de SGN e outro(s)                 ³±±
±±³          ³ ExpA3 =                                                    ³±±
±±³          ³ ExpO1 = objeto do SGN                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A206Aprov(cAliasSGN,cAprov,aArraySGN,aCampos,aCombo,oQual)
Local aStruSGN  := {}
Local cQuery    := ""
Local nX        := 0
Local lMT206AUS	:= ExistBlock("MT206AUS")
Local lContinua := .T.

dbSelectArea("SGN")
dbSetOrder(1)

cAliasSGN := "QRYSGN"
aStruSGN  := SGN->(dbStruct())
cQuery := "SELECT * "
cQuery += "FROM "+RetSqlName("SGN")+" "
cQuery += "WHERE GN_FILIAL='"+xFilial("SGN")+"' AND "
cQuery += "GN_USER='"+Substr(cAprov,1,6)+"' AND ( GN_STATUS='02' OR GN_STATUS='04' ) AND "
cQuery += "D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY "+SqlOrder(SGN->(IndexKey()))

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSGN)

For nX := 1 To len(aStruSGN)
	If aStruSGN[nX][2] <> "C" .And. FieldPos(aStruSGN[nX][1])<>0
		TcSetField(cAliasSGN,aStruSGN[nX][1],aStruSGN[nX][2],aStruSGN[nX][3],aStruSGN[nX][4])
	EndIf
Next nX
dbSelectArea(cAliasSGN)	

If Eof()
	aArraySGN := {{"","","","","",0,""}}
Else
	aArraySGN := {}
EndIf

While ( !(cAliasSGN)->(Eof()) .And. (cAliasSGN)->GN_FILIAL == xFilial("SGN") )
	
	If lMT206AUS
		lContinua := If (ValType(lContinua:= ExecBlock("MT206AUS",.F.,.F.)) == "L",lContinua,.T.)
	EndIf	
	
	If lContinua
		Aadd(aArraySGN,Array(Len(aCampos)))
		For nX := 1 to Len(aCampos)
			If Substr(aCampos[nX][1],1,2) == "GN"
				If aCampos[nX][2] == "N"
					aArraySGN[Len(aArraySGN)][nX] := Transform((cAliasSGN)->(FieldGet(FieldPos(aCampos[nX][1]))),PesqPict("SGN",aCampos[nX][1]))
				Else
					aArraySGN[Len(aArraySGN)][nX] := (cAliasSGN)->(FieldGet(FieldPos(aCampos[nX][1])))
				Endif
			EndIf
		Next nX
	EndIf
	
	(cAliasSGN)->(dbSkip())

EndDo

If oQual <> Nil
	oQual:SetArray(aArraySGN)
	oQual:bLine := { || aArraySGN[oQual:nAT] }
	oQual:Refresh()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga os arquivos de trabalho, cancela os filtros e restabelece as ordens originais.|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAliasSGN)
dbCloseArea()
	
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Fabio Alves Silva     ³ Data ³08/11/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados         ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()     

PRIVATE aRotina	:= {{OemToAnsi(STR0036),"Ma206Pesq",   0 , 1, 0, .F.},; //"Pesquisar"
						{OemToAnsi(STR0037),"A206Visual",  0 , 2, 0, nil},; //"Consulta"
						{OemToAnsi(STR0038),"A206Libera",  0 , 4, 0, nil},; //"Liberar"
						{OemToAnsi(STR0039),"A206Libera",  0 , 4, 0, nil},; //"Rejeitar"
						{OemToAnsi(STR0040),"A206Libera",  0 , 4, 0, nil},; //"Bloquear"
						{OemToAnsi(STR0041),"A206Ausente", 0 , 3, 0, nil},; //"Ausencia Temporaria"
						{OemToAnsi(STR0042),"A206Legend",  0 , 2, 0, .F.}}  //"Legenda"	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada utilizado para inserir novas opcoes no array aRotina  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("MTA206MNU")
	ExecBlock("MTA206MNU",.F.,.F.)
EndIf           
Return(aRotina) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A206ApSGN³ Autor ³ Rodrigo T. Silva		³ Data ³17.11.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Controla a liberacao de todos os niveis do produto pai	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MaAlcDoc(ExpA1,ExpD1,ExpN1)				               	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Numero do documento 					              ³±±
±±³          ³ ExpC2 = Tipo do documento                                  ³±±
±±³          ³ ExpC3 = Usuario de liberacao                               ³±±
±±³          ³ ExpC4 = Observacao do usuario que liberou                  ³±±
±±³          ³ ExpD1 = Data de Referencia                   			  ³±±
±±³          ³ ExpL1 = Libera todos os niveis                             ³±±
±±³          ³ ExpC5 = Operacao (3=Rejeicao;4=Liberacao;6=Bloqueio)		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA206                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A206ApSGN(cProduto,cTipo,cUsuario,cObs,dRefer,lTodosNiv,nTipoOper)
Local aArea     := GetArea()
Local aAreaSGG  := SGG->(GetArea())	  
Local lLibera   := .F.			

//-- Gera registro p/ aprovacao e chama recursivo para outros niveis
If SGG->(dbSeek(xFilial("SGG")+cProduto))			
	lLibera := MaAlcEng({cProduto,cTipo,cUsuario,"",cObs},dRefer,nTipoOper)
	While !SGG->(EOF()) .And. SGG->(GG_FILIAL+GG_COD) == xFilial("SGG")+cProduto		
		If lLibera
			//Atualiza Status
			Reclock("SGG",.F.)
			If nTipoOper == 3
				Replace GG_STATUS With "3"
			Else			
				Replace GG_STATUS With "2"
			EndIf
			MsUnlock()
		EndIf
		
		If lTodosNiv		
			A206ApSGN(SGG->GG_COMP,cTipo,cUsuario,cObs,,lTodosNiv,nTipoOper)
		EndIf
		
		SGG->(dbSkip())
	End
EndIf

RestArea(aAreaSGG)
RestArea(aArea)
Return
