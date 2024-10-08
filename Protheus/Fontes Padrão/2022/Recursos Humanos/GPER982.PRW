#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"        // incluido pelo assistente de conversao do AP5 IDE em 05/07/00
#INCLUDE "ETIQCT.CH"

Function GPER982()        // incluido pelo assistente de conversao do AP5 IDE em 05/07/00
Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F., {"",""} }) //[1]Acesso; [2]Ofusca; [3]Mensagem
Local aFldRel		:= {"RA_SALARIO", "RA_ADMISSA", "RA_REGISTR", "RA_FICHA", "RA_NUMCP", "RA_SERCP", "RA_DEMISSA"}
Local lBlqAcesso	:= aOfusca[2] .And. !Empty( FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRel ) )
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
SetPrvt("NPULA,AVETOR,NALIN,AINFO,NORDEM,CFILDE")
SetPrvt("CFILATE,CCCDE,CCCATE,CMATDE,CMATATE,CNOMEDE")
SetPrvt("CNOMEATE,CCATEGORIA,DDTDE,DDTATE,CSINDICATO,NCOLUNAS")
SetPrvt("CESPESTAB,NTIPIMP,CINICIO,CHAVE,NCOL")
SetPrvt("CFIL,CTIPINSC,CCGC,CTIPPAGTO,CEXT,CTIPO")
SetPrvt("NCONT")

// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 05/07/00 ==> 	#DEFINE PSAY SAY

// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 05/07/00 ==> #INCLUDE "ETIQCT.CH"
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o    � ETIQCT   � Autor � R.H. - Aldo Marini    � Data � 05.12.97 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Emiss꼘 de Etiqueta de Contrato de Trabalho                낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿞intaxe   � ETIQCT                                                     낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros�                                                            낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      � Generico                                                   낢�
굇쳐컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             낢�
굇쳐컴컴컴컴컴컫컴컴컴컴쩡컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛rogramador � Data   � BOPS �  Motivo da Alteracao                     낢�
굇쳐컴컴컴컴컴컵컴컴컴컴탠컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿐merson     �06/01/03�------쿍uscar o codigo CBO no cadastro de funcoes낢�
굇�            �        �------쿭e acordo com os novos codigos CBO/2002.  낢�
굇쿐quipe RH   �08/09/05�078027쿌justar a impressao da expressao "Por Mes"낢�
굇�            �08/03/06�------쿮 "Por hora" para Estagiarios Mens/Horista낢�
굇쿗uciana     �06/07/09�016765쿌juste na string (CH) para exibir "CNPJ"  낢�
굇�            �        � /2009쿪o inves de "CGC".                        낢�
굇쿌lex        �19/08/09�020747쿌juste no Grupo de Campos filial          낢�
굇�            �        � /2009퀃ratamento para n�o considerar 2 posi寤es 낢�
굇�            �        �      쿯ixas.                                    낢�
굇쿐merson Camp�09/08/11�019627쿌juste no tamanho do nome do cargo e remo-낢�
굇�            �        � /2011녕�o de espaco extra, na mesma linha para  낢�
굇�            �        �      쿿ue a matricula nao sai fora da etiqueta. 낢�
굇쿎laudinei S.�12/03/14쿟IKHCH쿌juste em FChkET530() para permitir a     낢�
굇�            �        �      쿶mpressao de mais de uma pagina.          낢�
굇쿛aulo O.    �26/04/17쿏RHPAG쿌juste para tratar o tamanho do n�mero da 낢�
굇쿔nzonha     �        �-255  쿎TPS.                                     낢�
굇읕컴컴컴컴컴컨컴컴컴컴좔컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Define Variaveis Locais (Basicas)                            �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
cbTxt     := ''
cString := "SRA"  // alias do arquivo principal (Base)
aOrd    := {STR0001,STR0002,STR0003}		//"Matricula"###"Centro de Custo"###"Nome"
cDesc1  := STR0004								//"Emiss꼘 de Etiqueta de Contrato de Trabalho."
cDesc2  := STR0005								//"Ser� impresso de acordo com os parametros solicitados pelo"
cDesc3  := STR0006								//"usuario."

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Define Variaveis Private(Basicas)                            �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
lEnd     := .F.
aReturn  := {STR0007,1,STR0008,2,2,1,"",1 }		//"Zebrado"###"Administra뇙o"
NomeProg := "ETIQCT"
aLinha   := {" "," "," "}
nLastKey := 0
cPerg    := "GPR320"

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Variaveis Utilizadas na funcao IMPR                          �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
AT_PRG   := "ETIQCT"
wCabec0  := 2
wCabec1  := ""
wCabec2  := ""
Contfl   := 1
Li       := 0
nTamanho := "M"

//Tratamento de acesso a Dados Sens�veis
If lBlqAcesso
	//"Dados Protegidos- Acesso Restrito: Este usu�rio n�o possui permiss�o de acesso aos dados dessa rotina. Saiba mais em {link documenta豫o centralizadora}"
	Help(" ",1,aOfusca[3,1],,aOfusca[3,2],1,0)
	Return
EndIf

/*
旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
� Variaveis de Acesso do Usuario                               �
읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸*/
cAcessaSRA	:= &( " { || " + ChkRH( "ETIQCT" , "SRA" , "2" ) + " } " )

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Verifica as perguntas selecionadas                           �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
pergunte("GPR320",.F.)

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Variaveis utilizadas para parametros                         �
//� MV_PAR01        //  Filial De                                �
//� MV_PAR02        //  Filial Ate                               �
//� MV_PAR03        //  Centro de Custo De                       �
//� MV_PAR04        //  Centro de Custo Ate                      �
//� MV_PAR05        //  Matricula De                             �
//� MV_PAR06        //  Matricula Ate                            �
//� MV_PAR07        //  Nome De                                  �
//� MV_PAR08        //  Nome Ate                                 �
//� MV_PAR09        //  Categorias                               �
//� MV_PAR10        //  Periodo De                               �
//� MV_PAR11        //  Periodo Ate                              �
//� MV_PAR12        //  Sindicato (99 Todos)                     �
//� MV_PAR13        //  Numero de Colunas                        �
//� MV_PAR14        //  Esp.Estabelecimento                      �
//� MV_PAR15        //  Tipo Entrada/Saida                       �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Titulo := STR0009		//"EMISS랳 ETIQUETA DE CONTRATO DE TRABALHO"

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Envia controle para a funcao SETPRINT                        �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
wnrel:="ETIQCT"            //Nome Default do relatorio em Disco
wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

RptStatus({||GR530Imp()})// Substituido pelo assistente de conversao do AP5 IDE em 05/07/00 ==> 	RptStatus({||Execute(GR530Imp)})
Return Nil
// Substituido pelo assistente de conversao do AP5 IDE em 05/07/00 ==> 	function GR530Imp
Static function GR530Imp()

Local T

lEnd     := .F.

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Define Variaveis Locais (Programa)                           �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
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

aVetor:={}
nAlin :=0
aInfo :={}

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Carregando variaveis MV_PAR?? para Variaveis do Sistema.     �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
nOrdem     := aReturn[8]
cFilDe     := MV_PAR01
cFilAte    := MV_PAR02
cCcDe      := MV_PAR03
cCcAte     := MV_PAR04
cMatDe     := MV_PAR05
cMatAte    := MV_PAR06
cNomeDe    := MV_PAR07
cNomeAte   := MV_PAR08
cCategoria := MV_PAR09
dDtDe      := MV_PAR10
dDtAte     := MV_PAR11
cSindicato := MV_PAR12
nColunas   := If( MV_PAR13 > 4 , 4 , MV_PAR13 )
cEspEstab  := MV_PAR14
nTipImp    := MV_PAR15           // Verifica Etiq de Entrada/Saida

For T:=1 TO nColunas
	If nTipImp==1             // Etiq de Entrada
		aAdd(aVetor,{" "," "," "," "," "," "," "," "," "," "," "," "})
	Else
		aAdd(aVetor,{" "," "," "," "," "," "})
	Endif
Next

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
SetRegua(RecCount())

Chave := 0
Li    := PROW()
nCol  := 1
nAlin := 0
cFil  := Space(FWGETTAMFILIAL)

@Li,0 PSAY Chr(15)

While !Eof() .And. Chave == 0

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Movimenta Regua Processamento                                �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	IncRegua()

   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
   //� Verifica Quebra de Filial                                    �
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	If SRA->RA_FILIAL #cFil
		If !fInfo(@aInfo,SRA->RA_FILIAL)
			Exit
		Endif
		cFil:=SRA->RA_FILIAL
	Endif

	While !Eof() .And. SRA->RA_FILIAL == cFil

		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//� Movimenta Regua Processamento                                �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		IncRegua()

		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//� Verifica o De / Ate Solicitado                               �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
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

		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//� Cancela Impres�o ao se pressionar <ALT> + <A>                �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		If lEnd
			Chave := 1
			Exit
		EndIF

		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//� Consiste Parametriza눯o do Intervalo de Impress�o            �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
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

		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//� Verifica Situacao e Categoria do Funcionario                 �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		If !( SRA->RA_CATFUNC $ cCategoria )
			dbSkip()
			Loop
		Endif

		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//� Verifica Sindicatos - 99 Todos                               �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		If cSindicato #"99" .And. SRA->RA_SINDICA # cSindicato
			dbSkip()
			Loop
		EndIf

		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//� Verifica se for Tipo Saida - Imprime apenas demitidos        �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		If nTipImp==2
			If SRA->RA_SITFOLH#"D" .And. (SRA->RA_DEMISSA < dDtDe .Or. SRA->RA_DEMISSA > dDtAte)
				dbSkip()
				Loop
			Endif
		Else
			If SRA->RA_ADMISSA < dDtDe .Or. SRA->RA_ADMISSA > dDtAte
				dbSkip()
				Loop
			Endif
		Endif

		nAlin:=nAlin+1
		If nTipImp==1
			cTipInsc  := If (aInfo[15] == 1 ,"2","1" )
			cCgc      := If (cTipInsc == "2",aInfo[8],Transform(aInfo[8],"@R ##.###.###/####-##")) // CGC
			If SRA->RA_CATFUNC$"M*C*E"
				cTipPagto	:= 	STR0010			//-- Mensalista ( Mensalista/Comissionado/Estagiario mensalista)
			ElseIf SRA->RA_CATFUNC=="S"
				cTipPagto	:= 	STR0028			//-- Semanalista
			ElseIf SRA->RA_CATFUNC$"H*G"
				cTipPagto	:= 	STR0011 		//-- Horista      ( Horista/Estagiario horista)
			ElseIf 	SRA->RA_CATFUNC=="D"
				cTipPagto	:= 	STR0012   		//-- Diarista
			Else
				cTipPagto	:= 	If(SRA->RA_TIPOPGT="M",STR0010,STR0028) 			//-- Mensalista  * Semanlista
			Endif
			//-- cTipPagto := If(SRA->RA_CATFUNC$"M*C*E",STR0010,If(SRA->RA_CATFUNC="H*G",STR0011,STR0012))	//" POR MES"###" POR HRS"###" POR DIA"

			// - Monta Extenso do Salario			F530MTL()
			nTamanho:=50-Len(STR0013+ALLTRIM(TRANSFORM(SRA->RA_SALARIO,"@E 999,999,999.99"))+" ")	//Remuneracao R$ ou Bs
			cExt := "("+Extenso(SRA->RA_SALARIO,.F.,1)+") "+cTipPagto
			If Len(cExt)<=nTamanho
				aLinha[1]:= cExt
				aLinha[2]:= Space(50)
				aLinha[3]:=	Space(40)
			ElseIf Len(cExt)<=(49+nTamanho)
				aLinha[1]:= Left(cExt,nTamanho)
				aLinha[2]:= SubStr(cExt,nTamanho+1,50)
				aLinha[3]:=	Space(40)
			Else
				aLinha[1]:= Left(cExt,nTamanho)
				aLinha[2]:= SubStr(cExt,nTamanho+1,50)
				aLinha[3]:=	SubStr(cExt,nTamanho+50+1,40)
			Endif

			//

			aVetor[nAlin,1]:= aInfo[3]
			aVetor[nAlin,2]:= aInfo[4]
			aVetor[nAlin,3]:= AllTrim(aInfo[5]) + " - " + aInfo[6] + Iif(cPaisLoc =="BRA",STR0014 + cCgc,"")		//"  CGC "
			aVetor[nAlin,4]:= STR0015+cEspEstab		//"Esp. Estabelecimento "
			aVetor[nAlin,5]:= STR0016+ Iif(cPaisLoc=="BRA",SUBSTR(DescFun(SRA->RA_CODFUNC,SRA->RA_FILIAL),1,16) + STR0017 +  fCodCBO(SRA->RA_FILIAL,SRA->RA_CODFUNC,dDataBase),DescFun(SRA->RA_CODFUNC,SRA->RA_FILIAL))+"-"+ SRA->RA_FILIAL+"-"+SRA->RA_MAT	//"CARGO "###"  CBO "
			aVetor[nAlin,6]:= " "
			aVetor[nAlin,7]:= STR0018+SUBSTR(DTOC(SRA->RA_ADMISSA),1,2)+STR0019+MesExtenso(MONTH(SRA->RA_ADMISSA))+STR0019+STR(YEAR(SRA->RA_ADMISSA),4)	//"Data Admissao "###" de "###" de "
			aVetor[nAlin,8]:= STR0020+SRA->RA_REGISTR + STR0021 + SRA->RA_FICHA										//"Registro No. "###" Fls./Ficha "
			aVetor[nAlin,9]:= STR0022+ALLTRIM(TRANSFORM(SRA->RA_SALARIO,"@E 999,999,999.99"))+" "+aLinha[1]	//Remuneracao R$ ou Bs
			aVetor[nAlin,10]:= aLinha[2]
			aVetor[nAlin,11]:= " "
		Else
			aVetor[nAlin,1]:= STR0023+SRA->RA_FILIAL+"  "+STR0024+SRA->RA_MAT+"  "+STR0025+AllTrim(SRA->RA_NUMCP)+"/"+SRA->RA_SERCP	//"FIL.: "###"MATRIC: "###"CART.PROF: "
			aVetor[nAlin,2]:= STR0026+SUBSTR(DTOC(SRA->RA_DEMISSA),1,2)+STR0027+MesExtenso(MONTH(SRA->RA_DEMISSA))+STR0027+STR(YEAR(SRA->RA_DEMISSA),4)	//"Data Saida "###" de "###" de "
			aVetor[nAlin,3]:= " "
			aVetor[nAlin,4]:= " "
			aVetor[nAlin,5]:= " "
			aVetor[nAlin,6]:= " "
		Endif
		cTipo:="I"
		FChkET530()

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
FChkET530()

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Termino do Relatorio                                         �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
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
// Substituido pelo assistente de conversao do AP5 IDE em 05/07/00 ==> FuncTion FChkET530
Static FuncTion FChkET530()
*-------------------------------------

Local C
Local I

If (cTipo == "I" .And. nAlin == nColunas) .Or. (cTipo == "F" .And. nAlin > 0)
	nCont:=If(nTipImp==1,12,6) // Verifica Etiq de Entrada/Saida
	For C:= 1 To nCont
		nCol:=0
		For I:= 1 To nColunas
			@ Li,nCol PSAY substr(aVetor[I,C],1,56)
			nCol := nCol + 56
			aVetor[I,C]:= " "
		Next
		Li := Li + 1
		If Li >= 60
			Li :=0
		Endif
	Next

	nAlin:=0

Endif

If cTipo == "F"
	@ Li, 0 PSAY " "
Endif

Return(nil)        // incluido pelo assistente de conversao do AP5 IDE em 05/07/00
