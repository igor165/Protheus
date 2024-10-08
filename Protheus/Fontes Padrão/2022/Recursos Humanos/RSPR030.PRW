#include "rwmake.ch"   
#INCLUDE "RSR003.CH"

Function RSPR030()

Private aFldRot 	:= {'QG_NOME'}
Private aOfusca	 	:= If(FindFunction('ChkOfusca'), ChkOfusca(), {.T.,.F.}) //[1] Acesso; [2]Ofusca
Private lOfuscaNom 	:= .F. 
Private aFldOfusca 	:= {}

If aOfusca[2]
	aFldOfusca := FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRot ) // CAMPOS SEM ACESSO
	IF aScan( aFldOfusca , { |x| x:CFIELD == "QG_NOME" } ) > 0
		lOfuscaNom := FwProtectedDataUtil():IsFieldInList( "QG_NOME" )
	ENDIF
EndIf


//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("CDESC1,CDESC2,CDESC3,CSTRING,AORD,IMPRIME")
SetPrvt("LEND,ARETURN,NOMEPROG,ALINHA,NLASTKEY,CPERG")
SetPrvt("TITULO,AT_PRG,CCABEC,WCABEC0,WCABEC1,CONTFL")
SetPrvt("LI,NOPC,NOPCA,WNREL,NTAMANHO,L1VEZ")
SetPrvt("CCANCEL,CINISQG,CFIMSQG,NY,CALIAS,NREG")
SetPrvt("CINICIO,CFIM,CCODTESTE,CDETALHE,CDESCR,NLINHA")
SetPrvt("I,NNUM,CTESTE,CNOME")

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o    � RSP003   � Autor � Equipe R.H.           � Data � 03.03.98 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Imprime os teste conforme parametros selecionados          낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so       � RdMake                                                     낢�
굇쳐컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             낢�
굇쳐컴컴컴컴컴컫컴컴컴컴쩡컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛rogramador � Data   � BOPS �  Motivo da Alteracao                     낢�
굇쳐컴컴컴컴컴컵컴컴컴컴탠컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿎ecilia Car.�06/08/14쿟QENRX쿔ncluido o fonte da 11 para a 12 e efetua-낢�
굇�            �        �      쿭a a limpeza.                             낢�
굇읕컴컴컴컴컴컨컴컴컴컴좔컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�*/
cDesc1  := OemtoAnsi(STR0001) //"Este programa tem como objetivo imprimir os testes"
cDesc2  := OemtoAnsi(STR0002) //"conforme parametros selecionados."
cDesc3  := ""
cString := "SQG"  	
aOrd    := {}
Imprime := .T.
lEnd    := .F.

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Define Variaveis (Basicas)                            		  �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
aReturn  := { STR0003,1,STR0004,2,2,1,"",1 } //"Zebrado"###"Administracao"
NomeProg := "RSR003"
aLinha   := {}
nLastKey := 0
cPerg    := "RSR003"

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Define Variaveis (Programa)                                  �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Titulo  := OemToAnsi(STR0005) //"Teste"
At_prg  := "RSR003"
cCabec  := ""
wCabec0 := 0
wCabec1 := ""
ContFl  := 1
Li      := 1

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Verifica as perguntas selecionadas                           �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
pergunte("RSR003",.F.)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Variaveis utilizadas para parametros                         �
//� mv_par01        //  Teste de                                 �
//� mv_par02        //  Teste ate                                �
//� mv_par03        //  Personalizar (S/N)   			         �
//� mv_par04        //  Dt.Teste de     						 �
//� mv_par05        //  Dt.Teste ate			        		 �
//� mv_par06        //  Curriculo de                   		     �
//� mv_par07        //  Curriculo ate    			  			 �
//� mv_par08        //  Nome de          			  			 �
//� mv_par09        //  Nome ate         			  			 �
//� mv_par10        //  Qtd. a Imprimir  			  			 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Envia controle para a funcao SETPRINT                        �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
nOpc:=2
nOpca:=2
wnrel:="RSR003"   					//Nome Default do relatorio em Disco
wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd)

If nLastKey == 27
	Return 
EndIf

SetDefault(aReturn,cString)

If nLastKey == 27
	Return 
EndIf

RptStatus({|| F003Impr()})

Return 

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o    � F003Impr � Autor � R.H. - Cristina Ogura � Data � 03.03.98 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Rotina de impressao dos testes                             낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so       � RdMake                                                     낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Static Function F003Impr()
Local nY	:= 0
Local cBlqCV	:= SuperGetMv("MV_BLQCV",,"1") 

cCabec  := ""
At_prg  := "RSR003"
WCabec0 := 1
WCabec1 := OemtoAnsi(STR0006) //"Teste para candidatos"
Contfl  := 1
Li      := 0
nTamanho:= "M"    
l1Vez   := .T.
cCancel := STR0007 //"Cancelado pelo usuario"

If mv_par03 == 1		//Personalizar Sim
	dbSelectArea("SQD")
	dbSetOrder(2)
	dbSeek(xFilial("SQD")+mv_par06,.T.)
	cIniSQD:= "QD_FILIAL+QD_CURRIC"
	cFimSQD:= QD_FILIAL+mv_par07
	
	While !Eof() .And. &cIniSQD <= cFimSQD
       
      cNome := Fdesc("SQG",SQD->QD_CURRIC,"QG_NOME")
      If(lOfuscaNom,Replicate('*',15),cNome)

 		If Empty(SQD->QD_TESTE).Or.;
			( SQD->QD_DATA < mv_par04 .Or. SQD->QD_DATA > mv_par05 ) .Or.;
			( SQD->QD_CURRIC < mv_par06 .Or. SQD->QD_CURRIC > mv_par07 ) .Or.;
			( Upper(cNome) < Upper(mv_par08) .Or. Upper(cNome) > Upper(mv_par09) )

			dbSkip()
			Loop
		EndIf	

		IF SQG->(Columnpos("QG_ACTRSP")) > 0 .AND. SQG->QG_ACTRSP == '1' //1- sem aceite e 2-com aceite
			dbSkip()
			Loop
		ELSE
			IF cBlqCV == "2" .and. SQG->QG_ACEITE <> '2' ///BLOQUEAR O CV POR NAO ACEITE DO TERMO DE CONSENTIMENTO
				dbSkip()
				Loop
			ENDIF
		ENDIF

		R003Impri(SQD->QD_TESTE)
		
		dbSelectArea("SQD")
		dbSetOrder(2)
		dbSkip()
		
	EndDo
Else
	For nY := 1 To mv_par10
		R003Impri()
	Next nY
EndIf

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Termino do Relatorio                                         �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
dbSelectArea("SQQ")
dbSetOrder(1)
dbGoTop()

Set Device To Screen
Set Printer To
Commit

If aReturn[5] == 1
	Ourspool(wnrel)
EndIf

MS_FLUSH()
Return 
         

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Rotina de Impressao				                                �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Static Function R003Impri(cTeste)
cAlias:= Alias()
nReg  := RecNo()

dbSelectArea("SQQ")
dbSetOrder(1)
If mv_par03 == 1		//Personalizar Sim
	dbSeek(xFilial("SQQ")+cTeste,.F.)
	cInicio := "QQ_FILIAL+QQ_TESTE"
	cFim	  := QQ_FILIAL+cTeste
Else
	dbSeek(xFilial("SQQ")+mv_par01,.T.)
	cInicio := "QQ_FILIAL+QQ_TESTE"
	cFim	  := QQ_FILIAL+mv_par02
EndIf
	

SetRegua( RecCount() )
cCodTeste:=""
While	!Eof() .And. &cInicio <= cFim

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Movimenta Regua Processamento                                �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	IncRegua()
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Cancela Impress�o ao se pressionar <ALT> + <A>               �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	If lEnd
		cDetalhe:= STR0008 //"Cancelado pelo Operador"
		Impr(cDetalhe,"P")
		Exit
	EndIf
	
	If cCodTeste #SQQ->QQ_TESTE
		R003Cabec()
		cCodTeste:= SQQ->QQ_TESTE
	EndIf	

	If li > 55
		cDetalhe:=""
		Impr(cDetalhe,"P")
	EndIf
	
	R003Questoes()
	
	If li > 55
		cDetalhe:=""
		Impr(cDetalhe,"P")
	EndIf
	
	R003Alternat()
	
	dbSelectArea("SQQ")
	dbSkip()

EndDo

cDetalhe:=""
Impr(cDetalhe,"F")

dbSelectArea(cAlias)
dbGoto(nReg)

Return

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o    � R003Cabec� Autor � R.H. - Cristina Ogura � Data � 03.03.98 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Monta o cabecalho do teste dependendo da opcao selecionada 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so       � RdMake                                                     낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Static Function R003Cabec()
If mv_par03 == 1			// Personalizar Sim
	cDetalhe:= Space(02)+OemtoAnsi(STR0009)+ SQG->QG_CURRIC+Space(03)+OemtoAnsi(STR0010)+If(lOfuscaNom,Replicate('*',15),SQG->QG_NOME) //"Cod: "###"Nome: "
	Impr(cDetalhe,"C")
EndIf
cDetalhe:=""
Impr(cDetalhe,"C")
cDetalhe := Space(02)+"** "+OemtoAnsi(STR0011)+SQQ->QQ_TESTE+" - "+SQQ->QQ_DESCRIC //"Teste: "
Impr(cDetalhe,"C")
cDetalhe:=""
Impr(cDetalhe,"C")
Return 
	
/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴컫컴컴컴쩡컴컴컴컴엽�
굇쿑un뇚o    � R003Questoes� Autor � R.H.-Cristina Ogura � Data �03.03.98 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴컨컴컴컴좔컴컴컴컴눙�
굇쿏escri뇚o � Imprime as Questoes do Teste		    	                  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so       � RdMake                                                     낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/	
Static Function R003Questoes()
Local i	:= 0

cAlias:= Alias()
nReg  := RecNo()

dbSelectArea("SQO")
dbSetOrder(1)

If dbSeek(xFilial("SQQ")+SQQ->QQ_QUESTAO)
	cDescr:= Alltrim(SQO->QO_QUEST)
	nLinha:= MLCount(cDescr,115)
	For i := 1 to nLinha
		cDetalhe:= Space(05)+IIF(i==1,SQQ->QQ_ITEM+"- ",Space(Len(SQQ->QQ_ITEM))+"  ")+MemoLine(cDescr,115,i)
		Impr(cDetalhe,"C")
	Next i	
EndIf

dbSelectArea(cAlias)
dbGoto(nReg)

Return
	
/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o    � R003Alternat� Autor � Cristina Ogura     � Data � 03.03.98 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Imprime as Alternativas das questoes                       낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so       � RdMake                                                     낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/	
Static Function R003Alternat()
Local i	:= 0

cAlias:= Alias()
nReg  := RecNo()
nNum  := 96

If Empty(SQO->QO_ESCALA)

	dbSelectArea("SQP")
	dbSetOrder(1)
	If dbSeek(xFilial("SQQ")+SQQ->QQ_QUESTAO)
	
		While !Eof() .And. xFilial("SQQ")+SQQ->QQ_QUESTAO == QP_FILIAL+QP_QUESTAO
			cDescr:= Alltrim(SQP->QP_DESCRIC)
			nLinha:= MLCount(cDescr,110)
			nNum:= nNum + 1
			For i := 1 to nLinha
				cDetalhe:= IIF(i==1,Space(10)+"("+CHR(nNum)+")- ",Space(13))+Memoline(cDescr,110,i,,.T.)
				Impr(cDetalhe,"C")
			Next i	
			dbSkip()
		EndDo
	Else
		cDetalhe:=""
		For i:=1 To 4
			Impr(cDetalhe,"C")
		Next i
	EndIf
	
Else

	dbSelectArea("RBL") 
	dbSetOrder(1)
	If dbSeek(xFilial("RBL")+SQO->QO_ESCALA)
	
		While !Eof() .And. xFilial("RBL")+SQO->QO_ESCALA == RBL->RBL_FILIAL+RBL->RBL_ESCALA
			cDescr:= Alltrim(RBL->RBL_DESCRI)
			nLinha:= MLCount(cDescr,110)
			nNum:= nNum + 1
			For i := 1 to nLinha
				cDetalhe:= IIF(i==1,Space(10)+"("+CHR(nNum)+")- ",Space(13))+Memoline(cDescr,110,i,,.T.)
				Impr(cDetalhe,"C")
			Next i	
			dbSkip()
		EndDo
	Else
		cDetalhe:=""
		For i := 1 To 4
			Impr(cDetalhe,"C")
		Next i
	EndIf

EndIf
	
cDetalhe:=""
Impr(cDetalhe,"C")

dbSelectArea(cAlias)
dbGoto(nReg)

Return
