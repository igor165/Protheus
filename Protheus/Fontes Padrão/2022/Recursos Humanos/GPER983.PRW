#Include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 19/11/99
#INCLUDE "ETIQFER.CH"

Function GPER983()        // incluido pelo assistente de conversao do AP5 IDE em 19/11/99

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("CBTXT,CSTRING,AORD,CDESC1,CDESC2,CDESC3")
SetPrvt("LEND,ARETURN,NOMEPROG,ALINHA,NLASTKEY,CPERG")
SetPrvt("AT_PRG,WCABEC0,WCABEC1,WCABEC2,CONTFL,LI")
SetPrvt("NTAMANHO,TITULO,WNREL,CMOSTRA,CDET,NTOT")
SetPrvt("CCAB,CNOME,CFIM,NTAM,NLC,NLN")
SetPrvt("NPULA,AFERIAS,NALIN,NORDEM,CFILDE,CFILATE")
SetPrvt("CCCDE,CCCATE,CMATDE,CMATATE,CNOMEDE,CNOMEATE")
SetPrvt("CCATEGORIA,DDTFDE,DDTFATE,CSINDICATO,NCOLUNAS")
SetPrvt("CINICIO,CHAVE,NCOL,CFIL,CDATABO,CABONO")
SetPrvt("CTIPO")

// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 19/11/99 ==> 	#DEFINE PSAY SAY

// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 19/11/99 ==> #INCLUDE "ETIQFER.CH"

/*
_____________________________________________________________________________
└└└└└└└└└└└└└└└└└└└└└└└└└└└└└└└└└└└└└└�
└+-----------------------------------------------------------------------+└
└쪭un裔o    � Etiqfer  � Autor � R.H. - Aldo Marini    � Data � 05.12.97 └�
└+----------+------------------------------------------------------------└�
└쪫escri裔o � Emiss�o de Etiqueta de Anotacoes de Ferias                 └�
└+----------+------------------------------------------------------------└�
└쪺intaxe   � Etiqfer                                                    └�
└+----------+------------------------------------------------------------└�
└쪷arametros�                                                            └�
└+----------+------------------------------------------------------------└�
└� Uso      � RdMake                                                     └�
└+-----------------------------------------------------------------------└�
└�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             └�
└+-----------------------------------------------------------------------└�
└쪷rogramador � Data   � BOPS �  Motivo da Alteracao                     └�
└+------------+--------+------+------------------------------------------└�
└쪪ristina    �02/06/98쫥xxxxx� Conversao para outros idiomas.           └�
└쪴arina      �30/08/00쫂XXXXX� Validacao Filial/Acesso.Limpeza DOS.     └�
└쪴arcelo     �27/03/08�141592� Impressao de Etiquetas considerando o    └�
└�            �        �      � campo RH_ABOPEC ou o Parametro MV_ABOPEC └�
└�            �        �      � conforme a parametrizacao definida.      └�
└쪬merson Camp�15/08/11�019651쪨juste na impress�o da Filial / Matricula └�
└�            �        � /2011쫝ue estava ultrapassando o espaco da etiq.└�
└쪪laudinei S.�24/02/14쪻IJBX8쪨juste em FChkET520() para permitir a     └�
└�            �        �      쫒mpressao de mais de uma pagina.          └�
└쪷aulo O.    �26/04/17쪫RHPAG쪨juste em GR520Imp() para tratar o tamanho└�
└쪰nzonha     �        �-255  쫉o n�mero da CTPS.                        └�
└+-----------------------------------------------------------------------+└
└└└└└└└└└└└└└└└└└└└└└└└└└└└└└└└└└└└└└└�
����������������������������������������������������������������������������� */
//+--------------------------------------------------------------+
//� Define Variaveis Locais (Basicas)                            �
//+--------------------------------------------------------------+
cbTxt   := ''
cString := "SRA"  // alias do arquivo principal (Base)
aOrd    := {STR0001,STR0002,STR0003}	//"Matricula"###"Centro de Custo"###"Nome"
cDesc1  := STR0004							//"Emiss�o de Etiqueta de Anota�oes de F�rias."
cDesc2  := STR0005							//"Ser� impresso de acordo com os parametros solicitados pelo"
cDesc3  := STR0006							//"usuario."

//+--------------------------------------------------------------+
//� Define Variaveis Private(Basicas)                            �
//+--------------------------------------------------------------+
lEnd     := .F.
aReturn  := {STR0007,1,STR0008,2,2,1,"",1 }	//"Zebrado"###"Administra醴o"
NomeProg := "ETIQFER"
aLinha   := {}
nLastKey := 0
cPerg    := "GPR320"

//+--------------------------------------------------------------+
//� Variaveis Utilizadas na funcao IMPR                          �
//+--------------------------------------------------------------+
AT_PRG   := "ETIQFER"
wCabec0  := 2
wCabec1  := ""
wCabec2  := ""
Contfl   := 1
Li       := 0
nTamanho := "M"

/*
旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
� Variaveis de Acesso do Usuario                               �
읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸*/
cAcessaSRA	:= &( " { || " + ChkRH( "ETIQFER" , "SRA" , "2" ) + " } " )

//+--------------------------------------------------------------+
//� Verifica as perguntas selecionadas                           �
//+--------------------------------------------------------------+
pergunte("GPR320",.F.)

//+--------------------------------------------------------------+
//� Variaveis utilizadas para parametros                         �
//� mv_par01        //  Filial De                                �
//� mv_par02        //  Filial Ate                               �
//� mv_par03        //  Centro de Custo De                       �
//� mv_par04        //  Centro de Custo Ate                      �
//� mv_par05        //  Matricula De                             �
//� mv_par06        //  Matricula Ate                            �
//� mv_par07        //  Nome De                                  �
//� mv_par08        //  Nome Ate                                 �
//� mv_par09        //  Categorias                               �
//� mv_par10        //  Periodo De                               �
//� mv_par11        //  Periodo Ate                              �
//� mv_par12        //  Sindicato (99 Todos)                     �
//� mv_par13        //  Numero de Colunas                        �
//� mv_par14        //  Esp.Estabelecimento          *Nao Usado* �
//� mv_par15        //  Tipo Etiqueta Entrada/Saida  *Nao Usado* �
//+--------------------------------------------------------------+
Titulo := STR0009		//"EMISS횽 ETIQUETA DE ANOTACOES DE FERIAS"

//+--------------------------------------------------------------+
//� Envia controle para a funcao SETPRINT                        �
//+--------------------------------------------------------------+
wnrel:="ETIQFER"            //Nome Default do relatorio em Disco
wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

RptStatus({||GR520Imp()})// Substituido pelo assistente de conversao do AP5 IDE em 19/11/99 ==> 	RptStatus({||Execute(GR520Imp)})
Return Nil
// Substituido pelo assistente de conversao do AP5 IDE em 19/11/99 ==> 	function GR520Imp
Static function GR520Imp()

Local T

//+--------------------------------------------------------------+
//� Define Variaveis Locais (Programa)                           �
//+--------------------------------------------------------------+
lEnd    := .F.
cMostra := "S"
cDet    := ""
nTot    := ""
cCab    := ""
cNome   := ""
cFim    := ""
nTam    := 0
nLC     := 189
nLN     := 105
nPula   := 1
cAbono 	:= If(GetMv("MV_ABOPEC")=="S","1","2")

aFerias:={}  
nAlin  := 0

//+--------------------------------------------------------------+
//� Carregando variaveis mv_par?? para Variaveis do Sistema.     �
//+--------------------------------------------------------------+
nOrdem     := aReturn[8]
cFilDe     := mv_par01
cFilAte    := mv_par02
cCcDe      := mv_par03
cCcAte     := mv_par04
cMatDe     := mv_par05
cMatAte    := mv_par06
cNomeDe    := mv_par07
cNomeAte   := mv_par08
cCategoria := mv_par09
dDtfDe     := mv_par10
dDtfAte    := mv_par11
cSindicato := mv_par12
nColunas   := If( mv_par13 > 4 , 4 , mv_par13 )

For T:=1 TO nColunas
	aAdd(aFerias,{" "," "," "," "," "})
Next T

dbSelectArea( "SRA" )
If nOrdem == 1
	dbSetOrder( 1 )
ElseIf nOrdem == 2
	dbSetOrder( 2 )
ElseIf nOrdem == 3
	dbSetOrder(3)
Endif

dbGoTop()

If nOrdem == 1
	dbSeek(cFilDe + cMatDe,.T.)
	cInicio := "SRA->RA_FILIAL + SRA->RA_MAT"
	cFim    := cFilAte + cMatAte
ElseIf nOrdem == 2
	dbSeek(cFilDe + cCcDe + cMatDe,.T.)
	cInicio := "SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_MAT"
	cFim    := cFilAte + cCcAte + cMatAte
ElseIf nOrdem == 3
	DbSeek(cFilDe + cNomeDe + cMatDe,.T.)
	cInicio := "SRA->RA_FILIAL + SRA->RA_NOME + SRA->RA_MAT"
	cFim    := cFilAte + cNomeAte + cMatAte
Endif

dbSelectArea( "SRA" )
SetRegua(SRA->(RecCount()))

Chave := 0
Li    := PROW()
nCol  := 1
nAlin := 0

@LI ,0 PSAY chr(15)

dbSelectArea( "SRA" )
While !Eof() .And. Chave == 0
	cFil := SRA->RA_FILIAL

	//+--------------------------------------------------------------+
	//� Movimenta Regua Processamento                                �
	//+--------------------------------------------------------------+
	IncRegua()

	While !Eof() .And. SRA->RA_FILIAL == cFil 

		//+--------------------------------------------------------------+
		//� Movimenta Regua Processamento                                �
		//+--------------------------------------------------------------+
		IncRegua()

		//+--------------------------------------------------------------+
		//� Verifica o De / Ate Solicitado                               �
		//+--------------------------------------------------------------+
		If nOrdem == 1
			If SRA->RA_FILIAL + SRA->RA_MAT > cFilAte + cMatAte
				Chave := 1
				Exit
			Endif
		Elseif nOrdem == 2
			If SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_MAT > cFilAte + cCcAte + cMatAte
				Chave := 1
				Exit
			Endif
		Elseif nOrdem == 3
			If SRA->RA_FILIAL + SRA->RA_NOME + SRA->RA_MAT > cFilAte + cNomeAte + cMatAte
				Chave := 1
				Exit
			Endif
		Endif

		//+--------------------------------------------------------------+
		//� Cancela Impres쫛 ao se pressionar <ALT> + <A>                �
		//+--------------------------------------------------------------+
	
		If lEnd
			Chave := 1
			Exit
		EndIF
	
		//+--------------------------------------------------------------+
		//� Consiste Parametriza獵o do Intervalo de Impress쫛            �
		//+--------------------------------------------------------------+
		If (Sra->Ra_Nome < cNomeDe) .Or. (Sra->Ra_Nome > cNomeAte) .Or. ;
		   (Sra->Ra_Mat < cMatDe) .Or. (Sra->Ra_Mat > cMatAte) .Or. ;
			(Sra->Ra_CC < cCcDe) .Or. (Sra->Ra_CC > cCCAte)
			dbSkip(1)
			Loop
		EndIf
		
    	/*
		旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		쿎onsiste Filiais e Acessos                                             �
		읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�*/
		IF !( SRA->RA_FILIAL $ fValidFil() .and. Eval( cAcessaSRA ) )
			dbSelectArea("SRA")
      		dbSkip()
       		Loop
		EndIF
			
		//+--------------------------------------------------------------+
		//� Verifica Situacao e Categoria do Funcionario                 �
		//+--------------------------------------------------------------+
		If !( SRA->RA_CATFUNC $ cCategoria )
			dbSkip()
			Loop
		Endif
	
		//+--------------------------------------------------------------+
		//� Verifica Sindicatos - 99 Todos                               �
		//+--------------------------------------------------------------+
		If cSindicato #"99" .And. SRA->RA_SINDICA # cSindicato
			dbSkip()
			Loop
		EndIf

		//+--------------------------------------------------------------+
		//� Procura No Arquivo de Ferias o Periodo a Ser Listado         �
		//+--------------------------------------------------------------+
		dbSelectArea( "SRH" )
		If dbSeek( SRA->RA_FILIAL + SRA->RA_MAT )
			While !Eof() .And. SRA->RA_FILIAL + SRA->RA_MAT == SRH->RH_FILIAL + SRH->RH_MAT

				lAbopec := !Empty(SRH->RH_ABOPEC)	//SE O PERIODO DE ABONO PECUNIARIO FOI DEFINIDO NA HORA DO CALCULO
				cDatAbo := "NAO"
				
				If SRH->RH_DATAINI >= dDtfDe .And. SRH->RH_DATAINI <= dDtfAte

					If SRH->RH_DABONPE > 0 .And. lAbopec	//DIAS ABONO PECUNIARIO # PERIODO DE ABONO
						If SRH->RH_ABOPEC == "1"
							cDatAbo:= DtoC(SRH->RH_DATAINI-SRH->RH_DABONPE)+" A "+Dtoc(SRH->RH_DATAINI-1)
						ElseIf SRH->RH_ABOPEC == "2"
							cDatAbo:= DtoC( SRH->RH_DATAFIM + 1 )+" A "+Dtoc(SRH->RH_DATAFIM+SRH->RH_DABONPE)
						Endif
					ElseIf SRH->RH_DABONPE > 0 .And. !lAbopec   
						If cAbono == "1"	//PARAMETRO MV_ABOPEC = 'S'
							cDatAbo:= DtoC(SRH->RH_DATAINI-SRH->RH_DABONPE)+" A "+Dtoc(SRH->RH_DATAINI-1)
						Else
							cDatAbo:= DtoC( SRH->RH_DATAFIM + 1 )+" A "+Dtoc(SRH->RH_DATAFIM+SRH->RH_DABONPE)
						Endif
					Endif
                                           
					nALin:=nAlin+1  

					aFerias[nAlin,1]:= STR0010+SRA->RA_FILIAL+" "+STR0011+SRA->RA_MAT+" "+STR0012+AllTrim(SRA->RA_NUMCP)+"/"+SRA->RA_SERCP	//"FIL.: "###"MATRIC: "###"CART.PROF: "
					aFerias[nAlin,2]:= STR0013+DTOC(SRH->RH_DATABAS)+STR0014+DTOC(SRH->RH_DBASEAT)	//"PERIODO AQUISITIVO "###" A "
					aFerias[nAlin,3]:= STR0015+DTOC(SRH->RH_DATAINI)+STR0014+DTOC(SRH->RH_DATAFIM)	//"PERIODO GOZO       "###" A "
					aFerias[nAlin,4]:= STR0016+cDatAbo	//"PERIODO ABONO      "
					aFerias[nAlin,5]:= " " 

					cTipo:="I"
					FChkET520()

				Endif
				dbSkip()
			Enddo
         
		Endif

		dbSelectArea( "SRA" )
		dbSkip()

	Enddo

	IF Chave == 1
		Exit
	Endif

	If Eof()
		Exit
	Endif
Enddo
cTipo:="F"
FChkET520()

//+--------------------------------------------------------------+
//� Termino do Relatorio                                         �
//+--------------------------------------------------------------+
dbSelectArea( "SRA" )
Set Filter to
dbSetOrder(1)
Set Device To Screen

If aReturn[5] == 1
	Set Printer To
	Commit
	ourspool(wnrel)
Endif

MS_FLUSH()

*-------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 19/11/99 ==> FuncTion FChkET520
Static FuncTion FChkET520()
*-------------------------------------

Local C
Local I

If (cTipo == "I" .And. nAlin == nColunas) .Or. (cTipo == "F" .And. nAlin > 0)
	For C:= 1 To 5
		nCol:=0
		For I:= 1 To nColunas       
 			 @ Li,nCol PSAY aFerias[I,C]
			 nCol := nCol + 56
			 aFerias[I,C]:= " "
		Next
		Li := Li + 1
	Next

	Li := Li + 1
	nAlin:=0              

	If Li >= 60
  		Li :=0
	Endif    

Endif

If cTipo == "F"
	@ Li, 0 PSAY " "
Endif

Return .T.
