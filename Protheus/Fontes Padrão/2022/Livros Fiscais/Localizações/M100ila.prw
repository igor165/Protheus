#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 22/05/00
#include "SIGAWIN.CH"
#DEFINE _NOMEIMPOS 01
#DEFINE _ALIQUOTA  02
#DEFINE _BASECALC  03
#DEFINE _IMPUESTO  04
#DEFINE _RATEOFRET 11
#DEFINE _IVAFLETE  12
#DEFINE _RATEODESP 13
#DEFINE _IVAGASTOS 14
#DEFINE _VLRTOTAL  3
#DEFINE _FLETE     4
#DEFINE _GASTOS    5

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÕÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¸±±
±±³Funcao    ³                   M100ILA                 ³Data  13/11/2000   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Executa a funcao propria a cada pais para o calculo do ILA     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MATA101                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function M100ILA()

Local cFunc,aRet:={}

SetPrvt("ARET,CALIASROT,CORDEMROT,CFUNC,NBASE,NALIQ")
SetPrvt("LALIQ,LISENTO,AITEM,AIMP,CFIL,CAUX")
SetPrvt("AITEMINFO,AIMPOSTO,CIMPINCID,_ALIQILA,LCALC1,NI")
SetPrvt("NEE,CBUSCADEC,NDECI,CAREAX,CJUNTA,LMANUAL")
SetPrvt("NPOSQ,NQUANT,CTABELA,CPROD,NPRECO,NVALTOT")
SetPrvt("NVALPUB,NALICUOTA,NE,LRET,CTIPOCLI,CZONFIS")
SetPrvt("CTIPOFORN,CCFO,CVERIVA,")

cAliasRot:= Alias()
cOrdemRot:= IndexOrd()

cFunc:="M100ILA"+left(cPaisLoc,2)
cFunc:=cFunc+"()"
aRet:=&(cFunc)
dbSelectArea( cAliasRot )
dbSetOrder( cOrdemRot )
return(aRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³M100ILA   ¦ Autor ¦ Jose Cortes(Chile)     ¦ Data ¦ 13.11.00  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Programa que Calcula ILA   (CHILE)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MATA101                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Fernando M.   ³13/11/00³      ³Tratamento para desconto. Deve considerar ³±±
±±³              ³        ³      ³campo FC_LIQUIDO da TES                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function M100ILACH()

Local cAreax := "", cJunta := ""
Local nPosQ, cProd, lManual := .F.

SetPrvt("CALIASROT,CORDEMROT,AITEMINFO,AIMPOSTO,CIMPINCID,_ALIQILA")
SetPrvt("NI,NEE,CBUSCADEC,NDECI,CTABELA,NPRECO,NVALTOT,NVALBUB,NQUANT")


aItemINFO := ParamIxb[1]
aImposto  := aClone(ParamIxb[2])
cImpIncid := aImposto[10]
cCod      := aImposto[16]
If aItemINFO[1] == Nil
	nPosQ	:=	Ascan(aHeader,{ |X| Trim(X[2]) == "D1_QUANT"})
	nQuant	:=	aCols[n][nPosQ]  
	nPosQ1  :=	Ascan(aHeader,{ |X| Trim(X[2]) == "D1_COD"})
	cCOD	:=	aCols[n][nPosQ1]
	lManual := .T.
Else
    nQuant := aItemINFO[1]	
Endif	

lcalc1 := .f.
If cModulo =="FAT"
	dbSelectArea( "SA1" )
	If A1_tipo <>"N"
	   lcalc1 := .t.
	Endif
Else
	dbSelectArea( "SA2" )
	If A2_tipo <>"N"
	   lcalc1 := .t.
	Endif
Endif
If !lcalc1
	_aliqILA	:=	0.00
Else 
	DbSelectArea("SB1")
	If DbSeek(xFilial() + cCOD ) 
		_AliqILA := SB1->B1_ALIQILA
	Endif
	aImposto[2]  := _aliqIla                     // Alíquota ( 18 %)
	aImposto[11] := aItemINFO[4]		     	//Rateio do Frete
	aImposto[13] := aIteMINFO[5]     		    // Rateio de Despesas
	aImposto[3]  := aItemINFO[3]+aItemINFO[4]    // Base de Cálculo
	
    If Subs(aImposto[5],4,1) == "S"  .And. Len(AImposto) == 18 .And. ValType(aImposto[18])=="N"
		aImposto[3]	-=	aImposto[18]
	Endif
		
    nI := At( cImpIncid,";" )
    nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
	
   While nI > 1
      nEE:= AScan( aItemINFO[5],{|x| x[1] == Left(cImpIncid,nI-1) } )
      If nEE> 0
         aImposto[3] := aImposto[3]+aItemINFO[5,nEE,4]
      End
      cImpIncid := Stuff( cImpIncid,1,nI )
      nI := At( cImpIncid,";" )
      nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
   End

    cBuscaDec := "F2_VALIMP"+SFB->FB_CPOLVRO
	dbSelectArea("SX3")
	dbSetOrder(2)
	If dbSeek(cBuscaDec)
	   nDeci := SX3->X3_DECIMAL
	Else
	   nDeci := 2	
	Endif
	dbSetOrder(1)
	If cModulo =="FAT"
		dbSelectArea( "SA1" )	
	Else	
		dbSelectArea( "SA2" )	
   Endif
   aImposto[4] := Round((aImposto[2] * (aImposto[3]/100)),nDeci)   
  	
End
	
dbSelectArea( cAliasRot )
dbSetOrder( cOrdemRot )
Return( aImposto )
