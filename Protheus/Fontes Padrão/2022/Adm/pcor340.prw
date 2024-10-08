#INCLUDE "pcor340.ch"
#INCLUDE "PROTHEUS.CH"
/*/
_F_U_N_C_苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北矲UNCAO    � PCOR340  � AUTOR � Edson Maricate        � DATA � 27/08/2006 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰ESCRICAO � Programa de impressao do demonstrativo de saldos por visoes  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� USO      � SIGAPCO                                                      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砡DOCUMEN_ � PCOR340                                                      潮�
北砡DESCRI_  � Programa de impressao do demonstrativo de saldos por visoes  潮�
北砡FUNC_    � Esta funcao devera ser utilizada com a sua chamada normal a  潮�
北�          � partir do Menu do sistema.                                   潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function PCOR340(aPerg)
Local aArea		:= GetArea()
Local lOk		:= .F.
Local lEnd	:= .F.

Private aSavPar	
Private aVarPriv  //variavel que contera as variaveis privates a ser enxergadas pelo job

Private cCadastro := STR0001 //"Demonstrativo de Saldos"
Private nLin	:= 10000
Default aPerg := {}

If Len(aPerg) == 0
	oPrint := PcoPrtIni(cCadastro,,2,,@lOk,"PCR340")
Else
	aEval(aPerg, {|x, y| &("MV_PAR"+StrZero(y,2)) := x})
	oPrint := PcoPrtIni(cCadastro,,2,,@lOk,"")
EndIf

If lOk
	//salva parametros para nao conflitar com parambox
	aSavPar := {MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04, MV_PAR05, MV_PAR06, MV_PAR07}

	dbSelectArea("AKN")
	dbSetOrder(1)
	lOk := !Empty(MV_PAR01) .And. dbSeek(xFilial("AKN")+MV_PAR01)

	If lOk
		If SuperGetMV("MV_PCO_AKN",.F.,"2")!="1"  //1-Verifica acesso por entidade
			lOk := .T.                        // 2-Nao verifica o acesso por entidade
		Else
			nDirAcesso := PcoDirEnt_User("AKN", AKN->AKN_CODIGO, __cUserID, .F.)
		    If nDirAcesso == 0 //0=bloqueado
				Aviso(STR0006,STR0007,{},2)//"Aten玢o"###"Usuario sem acesso a esta configura玢o de visao gerencial. "###"Fechar"
				lOk := .F.
			Else
	    		lOk := .T.
			EndIf
		EndIf
	
		//impressao do relatorio
		If lOk
			aVarPriv := {}
			aAdd(aVarPriv, {"aSavPar", aClone(aSavPar)})
			aProcessa := PcoCubeVis(aSavPar[01],1               ,"Pcor340Sld",aSavPar[04],aSavPar[05],aSavPar[06],,aVarPriv)
			RptStatus( {|lEnd| PCOR340Imp(@lEnd,oPrint,aProcessa)})
		EndIf
	EndIf	
	//finaliza relatorio
	PcoPrtEnd(oPrint)
EndIf

RestArea(aArea)
	
Return


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    砅cor340Sld� Autor � Edson Maricate        � Data �18/02/2005潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o 矲uncao de processamento para impressao do dem. de saldos.   潮�
北�          矱sta funcao e chama pela pcocube nos niveis de processamento潮�
北�          硃arametrizados / ou pre configurados                        潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   砅cor340Sld                                                  潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�*/
Function Pcor340Sld(cConfig,cChave)
Local aRetFim
Local nCrdFim
Local nDebFim

aRetFim := PcoRetSld(cConfig,cChave,aSavPar[2])
nCrdFim := aRetFim[1, aSavPar[3]]
nDebFim := aRetFim[2, aSavPar[3]]

nSldFim := nCrdFim-nDebFim

Return {nSldFim}


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    砅cor340Imp� Autor � Edson Maricate        � Data �18/02/2005潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o 矲uncao de impressao do demonstrativo de saldo.              潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   砅COR340Imp(lEnd)                                            潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� lEnd - Variavel para cancelamento da impressao pelo usuario潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�*/
Static Function Pcor340Imp(lEnd,oPrint,aProcessa)

Local nx
Local cQuebra := ""
Local aColunas := {10,450,1200,1700}	
Local nColCod	:=	1
Local nColDesc:=	2
Local nColVal	:=	3
If aSavPar[07] <> 1
	aColunas := {450,1200,1700}	
	nColCod	:=	0
	nColDesc:=	1
	nColVal	:=	2           
Endif

PcoPrtCol(aColunas,.T.,2)

For nx := 1 To Len(aProcessa)
	If PcoPrtLim(nLin)
		nLin := 200
		PcoPrtCab(oPrint)
		nLin+=20
		PcoPrtCol(aColunas,.T.,2)
		If aSavPar[07]  == 1
			PcoPrtCell(PcoPrtPos(nColCod),nLin,PcoPrtTam(nColCod),30,STR0002,oPrint,2,1,RGB(230,230,230)) //"Codigo"
		Endif
		PcoPrtCell(PcoPrtPos(nColDesc),nLin,PcoPrtTam(nColDesc),30,STR0003,oPrint,2,1,RGB(230,230,230)) //"Descricao"
		PcoPrtCell(PcoPrtPos(nColVal),nLin,PcoPrtTam(nColVal),30,STR0004,oPrint,2,1,RGB(230,230,230)) //"Saldo Final"
		nLin+=70
	EndIf
	
	If lEnd
		PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),30,STR0005,oPrint,2,1,RGB(230,230,230)) //"Impressao cancelada pelo operador..."
	Endif

	If cQuebra<>aProcessa[nx,3]
		nLin+= 5
		PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),40,aProcessa[nx,3],oPrint,1,1,/*RgbColor*/)
		nLin+=45
		cQuebra := aProcessa[nx,3]
	EndIf
	Do Case
		Case aProcessa[nx,16] == "0" // Normal
			If aSavPar[07]  == 1
				PcoPrtCell(PcoPrtPos(nColCod),nLin,PcoPrtTam(nColCod),60,aProcessa[nx,1],oPrint,1,8,/*RgbColor*/) 
			Endif
			PcoPrtCell(PcoPrtPos(nColDesc),nLin,PcoPrtTam(nColDesc),60,aProcessa[nx,6],oPrint,1,8,/*RgbColor*/) 
			PcoPrtCell(PcoPrtPos(nColVal),nLin,PcoPrtTam(nColVal),60,Transform(aProcessa[nx,2,1],"@E 999,999,999,999.99"),oPrint,1,8,/*RgbColor*/,"",.T.) 
			nLin+=50			
		Case aProcessa[nx,16] == "1" // Negrito
			If aSavPar[07]  == 1
				PcoPrtCell(PcoPrtPos(nColCod),nLin,PcoPrtTam(nColCod),60,aProcessa[nx,1],oPrint,1,2,/*RgbColor*/) 
			Endif
			PcoPrtCell(PcoPrtPos(nColDesc),nLin,PcoPrtTam(nColDesc),60,aProcessa[nx,6],oPrint,1,2,/*RgbColor*/) 
			PcoPrtCell(PcoPrtPos(nColVal),nLin,PcoPrtTam(nColVal),60,Transform(aProcessa[nx,2,1],"@E 999,999,999,999.99"),oPrint,1,2,/*RgbColor*/,"",.T.) 
			nLin+=50			
		Case aProcessa[nx,16] == "2" // Total
			If aSavPar[07]  == 1
				PcoPrtCell(PcoPrtPos(nColCod),nLin,PcoPrtTam(nColCod),60,aProcessa[nx,1],oPrint,1,3,RGB(230,230,230)) 
			Endif
			PcoPrtCell(PcoPrtPos(nColDesc),nLin,PcoPrtTam(nColDesc),60,aProcessa[nx,6],oPrint,1,3,RGB(230,230,230)) 
			PcoPrtCell(PcoPrtPos(nColVal),nLin,PcoPrtTam(nColVal),60,Transform(aProcessa[nx,2,1],"@E 999,999,999,999.99"),oPrint,1,3,RGB(230,230,230),"",.T.) 
			nLin+=50			
		Case aProcessa[nx,16] == "3" // Linha sem valor
			If aSavPar[07]  == 1
  				PcoPrtCell(PcoPrtPos(nColCod),nLin,PcoPrtTam(nColCod),60,aProcessa[nx,1],oPrint,1,2,/*RgbColor*/) 
			Endif
			PcoPrtCell(PcoPrtPos(nColDesc),nLin,PcoPrtTam(nColDesc),60,aProcessa[nx,6],oPrint,1,2,/*RgbColor*/) 
			nLin+=50			
		Case aProcessa[nx,16] == "4" // traco
			If aSavPar[07]  == 1
				PcoPrtCell(PcoPrtPos(nColCod),nLin,PcoPrtTam(nColCod),20,"",oPrint,7,2,/*RgbColor*/) 
    		Endif
			PcoPrtCell(PcoPrtPos(nColDesc),nLin,PcoPrtTam(nColDesc),20,"",oPrint,7,2,/*RgbColor*/) 
			PcoPrtCell(PcoPrtPos(nColVal),nLin,PcoPrtTam(nColVal),20,"",oPrint,7,2,/*RgbColor*/,"",.T.) 
			nLin+=40						
	OtherWise
			If aSavPar[07]  == 1
				PcoPrtCell(PcoPrtPos(nColCod),nLin,PcoPrtTam(nColCod),45,aProcessa[nx,1],oPrint,1,1,/*RgbColor*/) 
			Endif	
			PcoPrtCell(PcoPrtPos(nColDesc),nLin,PcoPrtTam(nColDesc),45,aProcessa[nx,6],oPrint,1,1,/*RgbColor*/) 
			PcoPrtCell(PcoPrtPos(nColVal),nLin,PcoPrtTam(nColVal),45,Transform(aProcessa[nx,2,1],"@E 999,999,999,999.99"),oPrint,1,1,/*RgbColor*/,"",.T.) 
			nLin+=40
	EndCase	

Next
	
Return
