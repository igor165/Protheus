#INCLUDE "HSPAHRA9.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "TopConn.ch"
#define ESC       27
#define UNICO     "0"
#define GEMELAR_1 "1"
#define GEMELAR_2 "2"
#define GEMELAR_3 "3"
#define GEMELAR_4 "4"
#define GEMELAR_5 "5"
#define NAO       "0"
#define SIM       "1"
#define MASCULINO "0"
#define FEMININO  "1" 
#define CEZAREA   "0"
#define NORMAL    "1"
#define GRUPO_A   "0"
#define GRUPO_B   "1"
#define GRUPO_AB  "2"
#define GRUPO_O   "3"
#define POSITIVO  "1"
#define NEGATIVO  "0"
#define TRACE     repl("_",79)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHRA9  º Autor ³ MARCELO JOSE       º Data ³  08/07/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ RELACAO DE NASCIMENTO NO PERIODO                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHRA9()

// Declaracao de Variaveis
Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := "Recem-nascidos"
Local cPict          := ""
Local titulo         := "RESCEM-NASCIDOS"
Local nLin           := 80

Local Cabec1         := "Estatisticas Gerais do Cadastro( no periodo )"
Local Cabec2         := ""
Local imprime        := .T.
Local aOrd           := {}        
Local cPerg          := "HSPRA9"

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 80
Private tamanho      := "P"
Private nomeprog     := "HSPAHRA9" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        := 18
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "HSPAHRA9" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cString      := "GB2"  

If !Pergunte(cPerg,.T.)
	return
EndIf

// Monta a interface padrao com o usuario...
wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.T.)

If nLastKey == ESC 
  	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == ESC 
  	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

// Processamento RPTSTATUS monta janela com a regua de processamento.
RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

//******************************************************************************************************************
//Funcao     RUNREPORT  Autor : AP6 IDE               Data   08/07/04
//Descricao  Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS monta a janela com a regua de processamento.
//Uso        Programa principal

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local ntiponasc0 := 0, ntiponasc1 := 0, ntiponasc2 := 0, ntiponasc3 := 0, ntiponasc4 := 0, ntiponasc5 := 0
Local nGrupoA    := 0, nGrupoB    := 0, nGrupo_AB  := 0, nGrupoO    := 0, nFatorP    := 0, nFatorN    := 0
Local nprematN   := 0, nprematS   := 0
Local nsexoM     := 0, nsexoF     := 0
Local ntppartoC  := 0, ntppartoN  := 0
Local nTotNasc   := 0, nTotAlta   := 0
Local nLoop      := 0, nNumAlta   := 0
Local aTipoAlta  := {}
          
DbSelectArea("GF4")         // inicializa a matriz do tipo de alta
DbGoTop()
While !Eof()
 AADD(aTipoAlta,{GF4->GF4_TPALTA, GF4->GF4_DSTPAL ,0})
 DbSkip()
EndDo

dbSelectArea(cString)
dbSetOrder(4)

SetRegua(RecCount())   // SETREGUA -> Indica quantos registros serao processados para a regua

DbSeek(xFilial("GB2") + DTOS(MV_PAR01), .T.)
While !Eof() .And. GB2->GB2_FILIAL == xFilial("GB2") ;    // loop central de processamento 
            	.And.  GB2->GB2_DTNASC >= MV_par01      ;
            	.And.  GB2->GB2_DTNASC <= MV_par02
 
	If lAbortPrint // Verifica o cancelamento pelo usuario...		
	  		@nLin,00 PSAY STR0025
	  		Exit
	Endif     

 if GB2->GB2_TPNASC     == UNICO    ; ntiponasc0++      	// tipo de nascimento
	elseif GB2->GB2_TPNASC == GEMELAR_1; ntiponasc1++
	elseif GB2->GB2_TPNASC == GEMELAR_2; ntiponasc2++
	elseif GB2->GB2_TPNASC == GEMELAR_3; ntiponasc3++
	elseif GB2->GB2_TPNASC == GEMELAR_4; ntiponasc4++
	elseif GB2->GB2_TPNASC == GEMELAR_5; ntiponasc5++
	endif

 
 if GB2->GB2_GRUPOS == GRUPO_A; nGrupoA++                // grupo sanguineo
 elseif GB2->GB2_GRUPOS == GRUPO_B; nGrupoB++
 elseif GB2->GB2_GRUPOS == GRUPO_AB; nGrupo_AB++
 elseif GB2->GB2_GRUPOS == GRUPO_O; nGrupoO++
 endif
 
 if GB2->GB2_FATOR == POSITIVO; nFatorP++                // fator Rh
 elseif GB2->GB2_FATOR == NEGATIVO; nFatorN++
 endif

	iif(GB2->GB2_PREMAT == NAO, nprematN++, nprematS++)    	// prematuro 0=Nao / 1=sim

	iif(GB2->GB2_TIPO == CEZAREA, ntppartoC++, ntppartoN++)	// tipo do parto 0=Cesarea / 1=Normal

	iif(GB2->GB2_SEXO == MASCULINO, nsexoM++, nsexoF++)    	// Sexo 
 
 nTotNasc++

 if !EMPTY(GB2->GB2_TPALTA)
    for nLoop = 1 to LEN(aTipoAlta)
     if aTipoAlta[nLoop,1] == GB2->GB2_TPALTA
        nNumAlta := aTipoAlta[nLoop,3]+1
        aTipoAlta[nLoop,3] := nNumAlta
        nTotAlta++
     endif     
    next
 endif
 
	dbSkip() // Avanca o ponteiro do registro no arquivo

EndDo

// impressao da apuracao do loop central	
Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
nLin := 8
@ 10,05 Psay STR0008
@ 11,05 Psay STR0009+transform(ntiponasc0,"999")+CPCento(ntiponasc0,nTotNasc)
@ 12,05 Psay STR0010+transform(ntiponasc1,"999")+CPCento(ntiponasc1,nTotNasc) 
@ 13,05 Psay STR0011+transform(ntiponasc2,"999")+CPCento(ntiponasc2,nTotNasc) 
@ 14,05 Psay STR0012+transform(ntiponasc3,"999")+CPCento(ntiponasc3,nTotNasc) 
@ 15,05 Psay STR0013+transform(ntiponasc4,"999")+CPCento(ntiponasc4,nTotNasc) 
@ 16,05 Psay STR0014+transform(ntiponasc5,"999")+CPCento(ntiponasc5,nTotNasc) 
@ 17,00 Psay TRACE
@ 19,05 Psay STR0015
@ 20,05 Psay STR0016+transform(ntppartoN,"999")+CPCento(ntppartoN,nTotNasc)
@ 21,05 Psay STR0017+transform(ntppartoC,"999")+CPCento(ntppartoC,nTotNasc)
@ 22,00 Psay TRACE
@ 23,05 Psay STR0018
@ 24,05 Psay STR0019+transform(nprematN,"999")+CPCento(nprematN,nTotNasc)
@ 25,05 Psay STR0020+transform(nprematS,"999")+CPCento(nprematS,nTotNasc)
@ 26,00 Psay TRACE
@ 27,05 Psay STR0021
@ 28,05 Psay STR0022+transform(nsexoM,"999")+CPCento(nsexoM,nTotNasc)
@ 29,05 Psay STR0023+transform(nsexoF,"999")+CPCento(nsexoF,nTotNasc)
@ 30,00 Psay TRACE
@ 31,05 Psay STR0027
@ 32,05 Psay STR0028+transform(nGrupoA,"999")+CPCento(nGrupoA,nTotNasc)
@ 33,05 Psay STR0029+transform(nGrupoB,"999")+CPCento(nGrupoB,nTotNasc)
@ 34,05 Psay STR0030+transform(nGrupo_AB,"999")+CPCento(nGrupo_AB,nTotNasc)
@ 35,05 Psay STR0031+transform(nGrupoO,"999")+CPCento(nGrupoO,nTotNasc)
@ 36,00 Psay TRACE
@ 37,05 Psay STR0032
@ 38,05 Psay STR0033+transform(nFatorP,"999")+CPCento(nFatorP,nTotNasc)
@ 39,05 Psay STR0034+transform(nFatorN,"999")+CPCento(nFatorN,nTotNasc)
@ 40,00 Psay TRACE
@ 42,05 Psay STR0024+transform(nTotNasc,"999")
@ 43,00 Psay TRACE

nLin := 80

// impressao da pagina de tipo de alta
for nLoop = 1 to LEN(aTipoAlta)
	If nLin > 55 //Impressao do cabecalho do relatorio. Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8 
		@ nLin,05 Psay STR0026
		nLin := nLin+2
	Endif
 @ nLin, 05 Psay aTipoAlta[nLoop,1]+" - "+aTipoAlta[nLoop,2]+transform(aTipoAlta[nLoop,3],"999")
 nLin++
next
@ nLin,00 Psay TRACE
nLin := nLin+2
@ nLin,00 Psay STR0035+transform(nTotAlta,"999")+CPCento(nTotAlta,nTotNasc)+" dos nascimentos no periodo."
nLin++
@ nLin,00 Psay TRACE

SET DEVICE TO SCREEN  // Finaliza a execucao do relatorio...
	

If aReturn[5]==1      // Se impressao em disco, chama o gerenciador de impressao...
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif
	
MS_FLUSH()
	
Return
//******************************************************************************************************************

//  char _ADVPLdecl  CPCento(int, int) ==> calcula o percentual dos itens avaliados
Static function CPCento(p_calc,p_totcalc)

Local w_percent := ""
iif (p_calc > 0, w_percent := "  =  "+transform(((p_calc / p_totcalc) * 100),"999.99")+" %",  w_percent := "")
return(w_percent)

//******************************************************************************************************************