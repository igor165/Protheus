#INCLUDE "pcor350.ch"
#INCLUDE "PROTHEUS.CH"
/*/
_F_U_N_C_����������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���FUNCAO    � PCOR350  � AUTOR � Edson Maricate        � DATA � 07-01-2004 ���
���������������������������������������������������������������������������Ĵ��
���DESCRICAO � Programa de impressao do balancete por visoes gerenciais     ���
���������������������������������������������������������������������������Ĵ��
��� USO      � SIGAPCO                                                      ���
���������������������������������������������������������������������������Ĵ��
���_DOCUMEN_ � PCOR350                                                      ���
���_DESCRI_  � Programa de impressao do balancete configuravel por Tp.Saldo ���
���_FUNC_    � Esta funcao devera ser utilizada com a sua chamada normal a  ���
���          � partir do Menu do sistema.                                   ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function PCOR350(aPerg)
Local aArea		:= GetArea()
Local lOk		:= .F.
Local lEnd	:= .F.

Private aSavPar	
Private aVarPriv
Private cCadastro := STR0001 //"Balancete"
Private nLin	:= 10000
Default aPerg := {}

If Len(aPerg) == 0
	oPrint := PcoPrtIni(cCadastro,.T.,2,,@lOk,"PCR350")
Else
	aEval(aPerg, {|x, y| &("MV_PAR"+StrZero(y,2)) := x})
	oPrint := PcoPrtIni(cCadastro,.T.,2,,@lOk,"")
EndIf

If lOk

	//salva parametros para nao conflitar com parambox
	aSavPar := {MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR05,MV_PAR06,MV_PAR07}
	
	dbSelectArea("AKN")
	dbSetOrder(1)
	lOk := !Empty(MV_PAR01) .And. dbSeek(xFilial("AKN")+MV_PAR01)

	If lOk
		If SuperGetMV("MV_PCO_AKN",.F.,"2")!="1"  //1-Verifica acesso por entidade
			lOk := .T.                        // 2-Nao verifica o acesso por entidade
		Else
			nDirAcesso := PcoDirEnt_User("AKN", AKN->AKN_CODIGO, __cUserID, .F.)
		    If nDirAcesso == 0 //0=bloqueado
				Aviso(STR0009,STR0010,{STR0011},2)//"Aten��o"###"Usuario sem acesso a esta configura��o de visao gerencial. "###"Fechar"
				lOk := .F.
			Else
	    		lOk := .T.
			EndIf
		EndIf
	
		//impressao do relatorio
		If lOk
			aVarPriv := {}
			aAdd(aVarPriv, {"aSavPar", aClone(aSavPar)})
		
			//processamento do relatorio
			aProcessa := PcoCubeVis( MV_PAR01, 4, "Pcor350Sld", MV_PAR05, MV_PAR06, MV_PAR07, , aVarPriv)
			RptStatus( {|lEnd| PCOR350Imp(@lEnd,oPrint,aProcessa)})
		EndIf
	EndIf
	
	//finaliza relatorio
	PcoPrtEnd(oPrint)
EndIf


RestArea(aArea)
	
Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �PcoR350Sld� Autor � Edson Maricate        � Data �07-01-2004���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de impressao da planilha orcamentaria.               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �PcoR350Sld                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� lEnd - Variavel para cancelamento da impressao pelo usuario���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function PcoR350Sld(cConfig,cChave)
Local aRetIni,aRetFim
Local nCrdIni
Local nDebIni
Local nCrdFim
Local nDebFim

aRetIni := PcoRetSld(cConfig,cChave,aSavPar[2])
nCrdIni := aRetIni[1, aSavPar[4]]
nDebIni := aRetIni[2, aSavPar[4]]
aRetFim := PcoRetSld(cConfig,cChave,aSavPar[3])
nCrdFim := aRetFim[1, aSavPar[4]]
nDebFim := aRetFim[2, aSavPar[4]]

nSldIni := nCrdIni-nDebIni
nSldFim := nCrdFim-nDebFim
nMovCrd := nCrdFim-nCrdIni
nMovDeb := nDebFim-nDebIni


Return {nSldIni,nMovCrd,nMovDeb,nSldFim}


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �PcoR350Imp� Autor � Edson Maricate        � Data �07-01-2004���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de impressao da planilha orcamentaria.               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �PCOR350Imp(lEnd)                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� lEnd - Variavel para cancelamento da impressao pelo usuario���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function PcoR350Imp(lEnd,oPrint,aProcessa)

Local nx
Local cQuebra := ""

For nx := 1 To Len(aProcessa)
	If PcoPrtLim(nLin)
		nLin := 200
		PcoPrtCab(oPrint)
		nLin+=20
		PcoPrtCol({10,450,1200,1700,2100,2500,2900},.T.,2)
		PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),30,STR0002,oPrint,2,1,RGB(230,230,230)) //"Codigo"
		PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),30,STR0003,oPrint,2,1,RGB(230,230,230)) //"Descricao"
		PcoPrtCell(PcoPrtPos(3),nLin,PcoPrtTam(3),30,STR0004,oPrint,2,1,RGB(230,230,230)) //"Saldo Anterior"
		PcoPrtCell(PcoPrtPos(4),nLin,PcoPrtTam(4),30,STR0005,oPrint,2,1,RGB(230,230,230)) //"Movimento Credito"
		PcoPrtCell(PcoPrtPos(5),nLin,PcoPrtTam(5),30,STR0006,oPrint,2,1,RGB(230,230,230)) //"Movimento Debito"
		PcoPrtCell(PcoPrtPos(6),nLin,PcoPrtTam(6),30,STR0007,oPrint,2,1,RGB(230,230,230)) //"Saldo Final"
		nLin+=70
	EndIf
	
	If lEnd
		PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),30,STR0008,oPrint,2,1,RGB(230,230,230)) //"Impressao cancelada pelo operador..."
	Endif

	If cQuebra<>aProcessa[nx,3]
		nLin+= 25
		PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),60,aProcessa[nx,3],oPrint,1,2,/*RgbColor*/)
		nLin+=50
		cQuebra := aProcessa[nx,3]
	EndIf
	Do Case	
		Case aProcessa[nx,13] == "0" // Normal
			PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),60,aProcessa[nx,1],oPrint,1,8,/*RgbColor*/) 
			PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),60,aProcessa[nx,6],oPrint,1,8,/*RgbColor*/) 
			PcoPrtCell(PcoPrtPos(3),nLin,PcoPrtTam(3),60,Transform(aProcessa[nx,2,1],"@E 999,999,999,999.99"),oPrint,1,8,/*RgbColor*/,"",.T.) 
			PcoPrtCell(PcoPrtPos(4),nLin,PcoPrtTam(4),60,Transform(aProcessa[nx,2,2],"@E 999,999,999,999.99"),oPrint,1,8,/*RgbColor*/,"",.T.) 
			PcoPrtCell(PcoPrtPos(5),nLin,PcoPrtTam(5),60,Transform(aProcessa[nx,2,3],"@E 999,999,999,999.99"),oPrint,1,8,/*RgbColor*/,"",.T.) 
			PcoPrtCell(PcoPrtPos(6),nLin,PcoPrtTam(6),60,Transform(aProcessa[nx,2,4],"@E 999,999,999,999.99"),oPrint,1,8,/*RgbColor*/,"",.T.)
			nLin+=50			
		Case aProcessa[nx,13] == "1" // Negrito
			PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),60,aProcessa[nx,1],oPrint,1,2,/*RgbColor*/) 
			PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),60,aProcessa[nx,6],oPrint,1,2,/*RgbColor*/) 
			PcoPrtCell(PcoPrtPos(3),nLin,PcoPrtTam(3),60,Transform(aProcessa[nx,2,1],"@E 999,999,999,999.99"),oPrint,1,2,/*RgbColor*/,"",.T.) 
			PcoPrtCell(PcoPrtPos(4),nLin,PcoPrtTam(4),60,Transform(aProcessa[nx,2,2],"@E 999,999,999,999.99"),oPrint,1,2,/*RgbColor*/,"",.T.) 
			PcoPrtCell(PcoPrtPos(5),nLin,PcoPrtTam(5),60,Transform(aProcessa[nx,2,3],"@E 999,999,999,999.99"),oPrint,1,2,/*RgbColor*/,"",.T.) 
			PcoPrtCell(PcoPrtPos(6),nLin,PcoPrtTam(6),60,Transform(aProcessa[nx,2,4],"@E 999,999,999,999.99"),oPrint,1,2,/*RgbColor*/,"",.T.)
			nLin+=50			
		Case aProcessa[nx,13] == "2" // Total
			PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),60,aProcessa[nx,1],oPrint,1,3,RGB(230,230,230)) 
			PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),60,aProcessa[nx,6],oPrint,1,3,RGB(230,230,230)) 
			PcoPrtCell(PcoPrtPos(3),nLin,PcoPrtTam(3),60,Transform(aProcessa[nx,2,1],"@E 999,999,999,999.99"),oPrint,1,3,RGB(230,230,230),"",.T.) 
			PcoPrtCell(PcoPrtPos(4),nLin,PcoPrtTam(4),60,Transform(aProcessa[nx,2,2],"@E 999,999,999,999.99"),oPrint,1,3,RGB(230,230,230),"",.T.) 
			PcoPrtCell(PcoPrtPos(5),nLin,PcoPrtTam(5),60,Transform(aProcessa[nx,2,3],"@E 999,999,999,999.99"),oPrint,1,3,RGB(230,230,230),"",.T.) 
			PcoPrtCell(PcoPrtPos(6),nLin,PcoPrtTam(6),60,Transform(aProcessa[nx,2,4],"@E 999,999,999,999.99"),oPrint,1,3,RGB(230,230,230),"",.T.)
			nLin+=50			
		Case aProcessa[nx,13] == "3" // Linha sem valor
			PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),60,aProcessa[nx,1],oPrint,1,2,/*RgbColor*/) 
			PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),60,aProcessa[nx,6],oPrint,1,2,/*RgbColor*/) 
			nLin+=50			
		Case aProcessa[nx,13] == "4" // traco
			PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),20,"",oPrint,7,2,/*RgbColor*/) 
			PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),20,"",oPrint,7,2,/*RgbColor*/) 
			nLin+=40						
	OtherWise
		PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),45,aProcessa[nx,1],oPrint,1,1,/*RgbColor*/) 
		PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),45,aProcessa[nx,6],oPrint,1,1,/*RgbColor*/) 
		PcoPrtCell(PcoPrtPos(3),nLin,PcoPrtTam(3),45,Transform(aProcessa[nx,2,1],"@E 999,999,999,999.99"),oPrint,1,1,/*RgbColor*/,"",.T.) 
		PcoPrtCell(PcoPrtPos(4),nLin,PcoPrtTam(4),45,Transform(aProcessa[nx,2,2],"@E 999,999,999,999.99"),oPrint,1,1,/*RgbColor*/,"",.T.) 
		PcoPrtCell(PcoPrtPos(5),nLin,PcoPrtTam(5),45,Transform(aProcessa[nx,2,3],"@E 999,999,999,999.99"),oPrint,1,1,/*RgbColor*/,"",.T.) 
		PcoPrtCell(PcoPrtPos(6),nLin,PcoPrtTam(6),45,Transform(aProcessa[nx,2,4],"@E 999,999,999,999.99"),oPrint,1,1,/*RgbColor*/,"",.T.)
		nLin+=40
	EndCase	
Next
	
Return