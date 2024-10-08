// 浜様様様曜様様様様�
// � Versao � 0      �
// 藩様様様擁様様様様�

#INCLUDE "veicr540.ch"
#Include "fileio.ch"
#Include "protheus.ch"
/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    � VEICR540 � Autor �  Fabio                � Data � 19/10/99 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Cruzamento de Bolsa de Veiculos                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � (Veiculos)                                                 咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function VEICR540()
Local oReport
Local aArea := GetArea()
If FindFunction("TRepInUse") .and. TRepInUse()
	oReport := ReportDef()
	oReport:PrintDialog()
Else
	FS_VCR540R3()
EndIf
RestArea( aArea )
Return
        
/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � ReportDef� Autor � Andre Luis Almeida    � Data � 26/06/06 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Relatorio usando o TReport                                 咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Static Function ReportDef()
Local oReport
Local oSection1
Local oSection2
Local oCell

oReport := TReport():New("VEICR540",STR0001,"VCR540",{|oReport| VCR540IMP(oReport)})

oSection1 := TRSection():New(oReport,OemToAnsi("Secao 1"),{"VC4","VV2"})
TRCell():New(oSection1,"VC4_CHAINT","VC4",STR0002,,6)
TRCell():New(oSection1,"VC4_CONCES","VC4",STR0003,,28)
TRCell():New(oSection1,"VC4_VEI_CV",,STR0004,,,,{|| If(VC4->VC4_VEI_CV=="0",STR0012,If(VC4->VC4_VEI_CV=="1",STR0013,STR0014)) })
TRCell():New(oSection1,"VC4_NOVUSA",,STR0005,,,,{|| If(VC4->VC4_NOVUSA=="N",STR0015,STR0016) })
TRCell():New(oSection1,"VC4_CODMAR","VC4",STR0006,,4)
TRCell():New(oSection1,"VV2_DESMOD","VV2",STR0007,,20)

oSection2 := TRSection():New(oReport,OemToAnsi("Secao 2"),{"VC4"})
TRCell():New(oSection2,"VC4_FABMOD","VC4",STR0008,"@R 9999/9999")
TRCell():New(oSection2,"VC4_KILATU","VC4",STR0009,"@E 99,999,999")
TRCell():New(oSection2,"VC4_VALOFE","VC4",STR0010,"@E 99,999,999,999.99")
TRCell():New(oSection2,"VC4_DATINI","VC4",STR0011,"@D")

TRPosition():New(oSection1,"VV2",1,{|| xFilial()+VC4->VC4_CODMAR+VC4->VC4_MODVEI })

Return oReport

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � VCR540IMP� Autor � Andre Luis Almeida    � Data � 26/06/06 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Executa a impressao do relatorio do TReport                咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � Oficina                                                    咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function VCR540IMP(oReport)
Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(2)
PERGUNTE("VCR540",.F.)
DbSelectArea("VC4")
DbSetOrder(1)
DbSeek( xFilial("VC4") )
oReport:SetMeter(RecCount())
oSection1:Init()
oSection2:Init()
While !Eof() .and. !oReport:Cancel() .and. VC4_FILIAL == xFilial('VC4') 
	oReport:IncMeter()
	If ( Empty(MV_PAR01) .or. alltrim(MV_PAR01) == alltrim(VC4->VC4_CODMAR) ) .and. ( Empty(MV_PAR02) .or. alltrim(MV_PAR02) == alltrim(VC4->VC4_MODVEI) )
		If ( Empty(MV_PAR03) .or. VC4->VC4_DATINI >= MV_PAR03 ) .and. ( Empty(MV_PAR04) .or. VC4->VC4_DATINI <= MV_PAR04 )
			oSection1:PrintLine()
			oSection2:PrintLine()
			oReport:SkipLine()
		EndIf
    EndIf  
	DbSelectArea("VC4")
	DbSkip()
EndDo
oSection1:Finish()
oSection2:Finish()
Return Nil
         

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function FS_VCR540R3()

Private aReturn  := { OemToAnsi(STR0001), 1,OemToAnsi(STR0002), 2, 2, 2,,1 } //"Cruzamento de Bolsa de Veiculos "###"Transac"

cAlias    := "VC4"
cNomRel   := "VEIR540"
cPerg := "VCR540"
cTitulo   := STR0001 //"Cruzamento de Bolsa de Veiculos "
cDesc1    := STR0001 //"Cruzamento de Bolsa de Veiculos "
cDesc2    := cDesc3 := ""
lHabil    := .f.
cTamanho  := "P"

NomeRel := SetPrint(cAlias,cNomRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lHabil,,,cTamanho)

If nlastkey == 27
   Return
EndIf

SetDefault(aReturn,cAlias)

Set Printer to &NomeRel
Set Printer On
Set device to Printer

cbTxt    := Space(10)
cbCont   := 0
cString  := "VC1"
Li       := 80
m_Pag    := 1

wnRel    := "VEIR540"
nLin := 1

cTitulo:= STR0001 //"Cruzamento de Bolsa de Veiculos "
cabec1 := STR0002+" "+STR0003+Space(15)+STR0004+" "+STR0005+" "+STR0006+" "+STR0007 //"Transac"###"Concessionaria"###"Comp/Vend"###"Estado"###"Marca"###"Modelo"
cabec2 := STR0008+"   "+STR0009+Space(09)+STR0010+" "+STR0011 //"Fabricacao"###"Km Atual"###"Vl Oferta"###"Dt Oferta"

nomeprog:="VEIR540"
tamanho:="P"
nCaracter:=15
nTotal:=0

DbSelectArea("VC4")
DbSetOrder(1)
DbSeek( xFilial("VC4") )
//DbGoTop()
Do While !Eof().And. VC4_FILIAL == xFilial('VC4') 

   If (Empty(MV_PAR01).or. alltrim(MV_PAR01) == alltrim(VC4->VC4_CODMAR)).and.(empty(MV_PAR02) .or. alltrim(MV_PAR02) == alltrim(VC4->VC4_MODVEI)).and.;     
      (empty(MV_PAR03) .or.VC4->VC4_DATINI >= MV_PAR03).and.(Empty(MV_PAR04) .or. VC4->VC4_DATINI <= MV_PAR04)
      
   
	  If nLin == 1
	     nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
	  EndIf
	
	  @ nLin++,1 PSAY VC4->VC4_CHAINT+" "+Substr(VC4->VC4_CONCES,1,28)+"         "+If(VC4->VC4_VEI_CV=="0",STR0012,If(VC4->VC4_VEI_CV=="1",STR0013,STR0014))+Space(04)+If(VC4->VC4_NOVUSA=="N",STR0015,STR0016)+"  "+VC4->VC4_CODMAR+"   "+Posicione("VV2",1,xFilial("VV1")+VC4->VC4_CODMAR+VC4->VC4_MODVEI,"VV2_DESMOD") //"Compra"###"Venda "###"Avalia"###"Novo "###"Usado"
	
	  @ nLin++,1 PSAY Transform(VC4->VC4_FABMOD,"@R 9999/9999")+Space(01)+Transform(VC4->VC4_KILATU,"@E 99,999,999")+" "+Transform(VC4->VC4_VALOFE,"@E 99,999,999,999.99")+" "+Dtoc(VC4->VC4_DATINI)
	
	  If nLin > 60
	     nLin := 1
	  EndIf
   
   EndIf
   
   DbSelectArea("VC4")
   DbSkip()
   
EndDo

Eject

Set Printer to
Set device to Screen

MS_FLUSH()

OurSpool(NomeRel)

Return
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////