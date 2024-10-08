// 浜様様様曜様様様様�
// � Versao � 10     �
// 藩様様様擁様様様様�
#Include "OFIIA040.ch"

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    � OFIIA040 � Autor �  Renata               � Data � 25/11/99 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Gravacao dos dados do retorno da garantia SC               咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe   �                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � integracao                                                 咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OFIIA040

Private aCampos := {}
Private aRotina := { { STR0002 ,"axPesqui", 0 , 1},;
{ STR0003 ,"IA040V", 0 , 2 },;    //VIZUALIZAR
{ STR0004 ,"IA040I", 0 , 3 }}  //IMPORTA
//                     { STR0004 ,"IA040I", 0 , 4, 2}}  //IMPORTA
Private cCadastro := OemToAnsi(STR0001)   //"Importacao do retorno da Garantia
private cCodMar , cIndex , cChave , cCond , nIndex := 0

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Endereca a funcao de BROWSE                                  �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰

dbSelectArea("VG8")
dbSetOrder(1)

if !Pergunte("OFIMAR",.t.)
	return
endif

cCodMar := MV_PAR01

dbSelectArea("VI1")
cIndex  := CriaTrab(nil,.f.)
cChave  := IndexKey()
cCond   := 'VI1_CODMAR==cCodMar'
IndRegua("VI1",cIndex,cChave,,cCond,STR0007)

DbSelectArea("VI1")
nIndex := RetIndex("VI1")
#IFNDEF TOP
	dbSetIndex(cIndex+ordBagExt())
#ENDIF
dbSetOrder(nIndex+1)

mBrowse( 6, 1,22,75,"VI1")

dbSelectArea("VI1")
RetIndex()
DbsetOrder(1)
#IFNDEF TOP
	If File(cIndex+OrdBagExt())
		fErase(cIndex+OrdBagExt())
	Endif
#ENDIF

Return

/*
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    �IA040V    � Autor �Renata                 � Data � 25/11/99 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � visualiza os dados dos arquivos                            咳�
臼�          �                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe e � AxVisual(cAlias,nReg,nOpc,aCampos)                         咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Parametros�                                                            咳�
臼�          �                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Uso      � Generico                                                   咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function IA040V(cAlias,nReg,nOpc)

CPOIA040()
AxVisual(cAlias,nReg,nOpc,aCampos)

return

/*
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    �IA040I    � Autor �Renata                 � Data � 25/11/99 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � chama a funcao fs_codseg, feito dessa forma por causa do   咳�
臼�          � termometro                                                 咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe e � IA010I(cAlias,nReg,nOpc)                                   咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Parametros�                                                            咳�
臼�          �                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Uso      � INTEGRACAO                                                 咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function IA040I(cAlias,nReg,nOpc)

Private lMsHelpAuto := .t. , lMsErroAuto := .f. , lRet := .t.

Begin Transaction

Processa({|| FS_CODSEG()})

End Transaction

If !lRet
	MostraErro()
EndIf

return

/*
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    �FS_CODSEG � Autor �Renata                 � Data � 25/11/99 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Chama funcoes de gravacoes do VI1 (GARANTAIA) nos arquivos 咳�
臼�          � VG6/VG8                                                    咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe e � FS_CODSEG()                                                咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Parametros�                                                            咳�
臼�          �                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Uso      � integracao                                                 咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function FS_CODSEG()

private nReg := 0 , cAssunt , cAtendi , dDatRet ,	cNFCred , dDtCred

dbselectArea("VI1")
dbsetorder(2)
dbseek(xFilial("VI1"))

nReg := reccount()

ProcRegua(nReg)

do while !eof() .And. VI1->VI1_FILIAL == xFilial("VI1")
	
	if VI1->VI1_CODMAR # cCodmar
		dbskip()
		loop
	endif
	
	if VI1->VI1_TIPREG = "CRR"
		cAssunt := alltrim(VI1->VI1_ASSUNT)
		dDatRet := VI1->VI1_DATRET
		FS_CRITICA()
	elseif VI1->VI1_TIPREG = "ARR" //02
		cAssunt := alltrim(VI1->VI1_ASSUNT)
		dDatRet := VI1->VI1_DATRET
		FS_AVISO()
	elseif VI1->VI1_TIPREG = "ATR"  //03/04
		cAssunt := alltrim(VI1->VI1_ASSUNT)
		cAtendi := alltrim(VI1->VI1_ATENDI)
		cNFCred := VI1->VI1_NFCRED
		dDtCred := VI1->VI1_DTCRED
		dDatRet := VI1->VI1_DATRET
		nICMSA  := VI1->VI1_ICMSA
		nICMSR  := VI1->VI1_ICMSR
		nPickA  := VI1->VI1_PICKA
		nPickR  := VI1->VI1_PICKR
		nGuinA  := VI1->VI1_GUINA
		nGuinR  := VI1->VI1_GUINR
		nPickQA := VI1->VI1_QPICKA
		nPickQR := VI1->VI1_QPICKR
		nGuinQA := VI1->VI1_QGUINA
		nGuinQR := VI1->VI1_QGUINR
		FS_ATENDIDA()
		If !lRet
			return
		endif
		loop
	endif
	
	IncProc( OemtoAnsi(STR0006) )    //"Gravando dados da garantia!!"
	
	dbselectArea("VI1")
	dbskip()
	
enddo

dbselectArea("VI1")
if ExistBlock("OFA04DPGR") // O B S O L E T O
	ExecBlock("OFA04DPGR",.f.,.f.)
Endif

if ExistBlock("OA04DPGR")
	ExecBlock("OA04DPGR",.f.,.f.)
Endif



FS_DELIA40()  //DELETA O ARQUIVO VI1

return

/*
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    �FS_CRITICA� Autor �Renata                 � Data � 25/11/99 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Grava os dados dos registro CRITICA do VI1 nos arquivos    咳�
臼�          � VG6/VG8                                                    咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe e � FS_CRITICA()                                               咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Parametros�                                                            咳�
臼�          �                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Uso      � integracao                                                 咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function FS_CRITICA()

Private cAnoRrc , cNumRrc , cNumOsv

cAnoRrc := str(val(VI1->VI1_ANORRC),4)
cNumRrc := strzero(val(VI1->VI1_NUMRRC),7)
cCodMar := VI1->VI1_CODMAR
cNumOsv :=strzero(val(VI1->VI1_NUMOSV),8)


if FG_SEEK("VG8","cCodMar+cNumOsv+cAnoRrc+cNumRrc",1,.F.) = .T.
	
	If !RecLock("VG8",.F.)
		Help("  ",1,"REGNLOCK")
		lRet := .f.
		DisarmTransaction()
		Break
	EndIf
	
	VG8->VG8_DATRET := dDATRET
	VG8->VG8_SITRRC := "01"
	VG8->VG8_DESSIT := cASSUNT
	VG8->VG8_TRANSM := "N"
	MsUnlock()
	
	dbselectArea("VG6")
	dbgotop()
	dbsetorder(1)
	dbseek(xFilial("VG6")+cCodMar+cNUMOSV)
	
	
	do while !eof() .and. cNumOsv == VG6->VG6_NUMOSV .and. VG6->VG6_FILIAL == xFilial("VG6")
		
		If !RecLock("VG6",.F.)
			Help("  ",1,"REGNLOCK")
			lRet := .f.
			DisarmTransaction()
			Break
		EndIf
		
		VG6->VG6_TRANSM := "N"
		MsUnlock()
		
		dbskip()
		
	enddo
	
endif

return
/*
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    �FS_AVISO  � Autor �Renata                 � Data � 25/11/99 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Grava os dados dos registro AVISO   do VI1 nos arquivos    咳�
臼�          � VG6/VG8                                                    咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe e � FS_AVISO()                                                 咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Parametros�                                                            咳�
臼�          �                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Uso      � integracao                                                 咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function FS_AVISO()

Private cAnoRrc , cNumRrc , cNumOsv


cAnoRrc := str(val(VI1->VI1_ANORRC),4)
cNumRrc := strzero(val(VI1->VI1_NUMRRC),7)
cCodMar := VI1->VI1_CODMAR
cNumOsv :=strzero(val(VI1->VI1_NUMOSV),8)


if FG_SEEK("VG8","cCodMar+cNumOsv+cAnoRrc+cNumRrc",1,.F.) = .T.
	
	If !RecLock("VG8",.F.)
		Help("  ",1,"REGNLOCK")
		lRet := .f.
		DisarmTransaction()
		Break
	EndIf
	
	VG8->VG8_DATRET := dDATRET
	VG8->VG8_SITRRC := "02"
	VG8->VG8_DESSIT := cASSUNT
	MsUnlock()
	
endif

return

/*
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    �FS_ATENDIDA Autor �Renata                 � Data � 25/11/99 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Grava os dados dos registro ATENDIDA do VI1 nos arquivos   咳�
臼�          � VG6/VG8                                                    咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe e � FS_ATENDIDA()                                              咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Parametros�                                                            咳�
臼�          �                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Uso      � integracao                                                 咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function FS_ATENDIDA()

Local cTipMov := ""
Local nValIte := nValInd := nValMaoSC := nValMaoTC := nValCus := nValMat := nValDes := 0
Local nValQtdSC := nValLub := nKmPick := nKmGuin := NQtdPic := nQtdGui := 0
Local nValPer := 0 , nValTot := 0 , nBxaPec := 0 , nBxaSer := 0
Local nValdif := 0

Private cAnoRrc , cNumRrc , cNumOsv

if alltrim(VI1->VI1_ATENDI) = "LIQUIDADA"        //CREDITO
	cTipMov := "C"
elseif alltrim(VI1->VI1_ATENDI) = "ESTORNADA"    //DEBITO
	cTipMov := "D"
elseif VI1->VI1_VALPGT == 0 // se nao for pago nada ela eh passivel de reconsideracao
	cTipMov := "R"
else
	cTipMov := "C"
endif

cAnoRrc := strzero(val(VI1->VI1_ANORRC),4)
cNumRrc := strzero(val(VI1->VI1_NUMRRC),7)
cCodMar := VI1->VI1_CODMAR
cNumOsv :=strzero(val(VI1->VI1_NUMOSV),8)


do while !eof() .and. xfilial("VI1")+cCodMar+cNumOsv+cAnoRrc+cNumRrc == ;
	VI1->VI1_FILIAL+VI1->VI1_CODMAR+VI1->VI1_NUMOSV+VI1->VI1_ANORRC+VI1->VI1_NUMRRC
	
	if VI1->VI1_TIPREG = "EFH" //"EBI"
		
		dbselectArea("VG9")
		
		If !RecLock("VG9", !Found() )
			Help("  ",1,"REGNLOCK")
			lRet := .f.
			DisarmTransaction()
			Break
		EndIf
		
		VG9->VG9_FILIAL := xFilial("VG9")
		VG9->VG9_NUMOSV := cNumOsv
		VG9->VG9_ANORRC := cAnoRrc
		VG9->VG9_NUMRRC := cNumRrc
		VG9->VG9_DATMOV := dDATRET
		VG9->VG9_TIPMOV := cTipMov
		VG9->VG9_CODMAR := cCodmar
		VG9->VG9_RRCFAB := cNumRrc
		VG9->VG9_NFALHA := left(cAnoRrc,2)
		VG9->VG9_NRECON := right(cAnoRrc,2)
		
		//
		// esse trecho armazena em cada variavel e no VG9 os valores de cada tipo
		//
		//
		if alltrim(VI1->VI1_DESPGT) = "01"   //"PECAS"
			VG9->VG9_ITEPGT := VI1->VI1_VALPGT
			VG9->VG9_ITETRA := VI1->VI1_VALTRA
			nValIte += VI1->VI1_VALPGT
			
		elseif alltrim(VI1->VI1_DESPGT) = "10"  //"DESPESAS INDIR"
			VG9->VG9_INDPGT := VI1->VI1_VALPGT
			VG9->VG9_INDTRA := VI1->VI1_VALTRA
			nValInd += VI1->VI1_VALPGT
			
		elseif alltrim(VI1->VI1_DESPGT) = "02"  //"M.O. SCANIA"
			VG9->VG9_MAOPGT := VI1->VI1_VALPGT
			VG9->VG9_MAOTRA := VI1->VI1_VALTRA
			VG9->VG9_QTDPGT := VI1->VI1_QTDREC
			VG9->VG9_QTDTRA := VI1->VI1_QTDAPR
			nValMaoSc += VI1->VI1_VALPGT
			nValQtdSc += VI1->VI1_QTDAPR
			
		elseif alltrim(VI1->VI1_DESPGT) = "03"  //"M.O. TERCEIRO"
			VG9->VG9_MOTPGT := VI1->VI1_VALPGT
			VG9->VG9_MOTTRA := VI1->VI1_VALTRA
			nValMaoTc += VI1->VI1_VALPGT
			
		elseif alltrim(VI1->VI1_DESPGT) = "04"  //"MATERIAL TERC"
			VG9->VG9_CUSPGT := VI1->VI1_VALPGT
			VG9->VG9_CUSTRA := VI1->VI1_VALTRA
			nValMat += VI1->VI1_VALPGT
			
		elseif alltrim(VI1->VI1_DESPGT) = "05"  //"OLEO LUBRIFIC"
			VG9->VG9_LUBPGT := VI1->VI1_VALPGT
			VG9->VG9_LUBTRA := VI1->VI1_VALTRA
			nValLub += VI1->VI1_VALPGT
			
		elseif alltrim(VI1->VI1_DESPGT) = "06"  //"DIFERENCA ICMS"
			VG9->VG9_DIFPGT := VI1->VI1_VALPGT
			VG9->VG9_DIFTRA := VI1->VI1_VALTRA
			nValDif += VI1->VI1_VALPGT
			
		elseif alltrim(VI1->VI1_DESPGT) = "08"  //"KM PICK_UP"
			VG9->VG9_DESPGT := VI1->VI1_VALPGT
			VG9->VG9_DESTRA := VI1->VI1_VALTRA
			VG9->VG9_QTDPGT := VI1->VI1_QTDREC
			VG9->VG9_QTDTRA := VI1->VI1_QTDAPR
			nKmPick := VI1->VI1_VALPGT
			nQtdPic := VI1->VI1_QTDAPR
			
		elseif alltrim(VI1->VI1_DESPGT) = "07"  //"KM GUINCHO"
			VG9->VG9_GUIPGT := VI1->VI1_VALPGT
			VG9->VG9_GUITRA := VI1->VI1_VALTRA
			VG9->VG9_QTDPGT := VI1->VI1_QTDREC
			VG9->VG9_QTDTRA := VI1->VI1_QTDAPR
			nKMGuin := VI1->VI1_VALPGT
			nQtdGui := VI1->VI1_QTDAPR
			
		elseif alltrim(VI1->VI1_DESPGT) = "09"  //"PERMANENCIA"
			VG9->VG9_PERPGT := VI1->VI1_VALPGT
			VG9->VG9_PERTRA := VI1->VI1_VALTRA
			nValPer := VI1->VI1_VALPGT
			
		elseif alltrim(VI1->VI1_DESPGT) = "11"  //"TOTAL"
			VG9->VG9_TOTPGT := VI1->VI1_VALPGT
			VG9->VG9_TOTTRA := VI1->VI1_VALTRA
			nValTot := VI1->VI1_VALPGT
			
		endif
		MsUnlock()
		
		
	endif
	
	IncProc(OemtoAnsi(STR0006))
	dbselectArea("VI1")
	dbskip()
	
enddo

dbselectArea("VG9")

RecLock("VG9",.t. )
VG9->VG9_FILIAL := xFilial("VG9")
VG9->VG9_NUMOSV := cNumOsv
VG9->VG9_ANORRC := cAnoRrc
VG9->VG9_NUMRRC := cNumRrc
VG9->VG9_DATMOV := dDATRET
VG9->VG9_TIPMOV := cTipMov
VG9->VG9_CODMAR := cCodmar
VG9->VG9_DIFPGT := nICMSA // VI1->VI1_VALPGT
VG9->VG9_DIFTRA := nICMSR // VI1->VI1_VALTRA
VG9->VG9_CODMAR := cCodmar
VG9->VG9_RRCFAB := cNumRrc
VG9->VG9_NFALHA := left(cAnoRrc,2)
VG9->VG9_NRECON := right(cAnoRrc,2)
nValDif := nICMSA // VI1->VI1_VALPGT
msunlock()

RecLock("VG9",.t. )
VG9->VG9_FILIAL := xFilial("VG9")
VG9->VG9_NUMOSV := cNumOsv
VG9->VG9_ANORRC := cAnoRrc
VG9->VG9_NUMRRC := cNumRrc
VG9->VG9_DATMOV := dDATRET
VG9->VG9_TIPMOV := cTipMov
VG9->VG9_DESPGT := nPickA// VI1->VI1_VALPGT
VG9->VG9_DESTRA := nPickR// VI1->VI1_VALTRA
VG9->VG9_QTDPGT := nPickQA// VI1->VI1_QTDREC
VG9->VG9_QTDTRA := nPickQR// VI1->VI1_QTDAPR
VG9->VG9_CODMAR := cCodmar
VG9->VG9_RRCFAB := cNumRrc
VG9->VG9_NFALHA := left(cAnoRrc,2)
VG9->VG9_NRECON := right(cAnoRrc,2)
nKmPick := nPickA // VI1->VI1_VALPGT
nQtdPic := nPickQA // VI1->VI1_QTDAPR
msunlock()

RecLock("VG9",.t. )
VG9->VG9_FILIAL := xFilial("VG9")
VG9->VG9_NUMOSV := cNumOsv
VG9->VG9_ANORRC := cAnoRrc
VG9->VG9_NUMRRC := cNumRrc
VG9->VG9_DATMOV := dDATRET
VG9->VG9_TIPMOV := cTipMov
VG9->VG9_GUIPGT := nGuinA  // VI1->VI1_VALPGT
VG9->VG9_GUITRA := nGuinR  // VI1->VI1_VALTRA
VG9->VG9_QTDPGT := nGuinQA // VI1->VI1_QTDREC
VG9->VG9_QTDTRA := nGuinQR // VI1->VI1_QTDAPR
VG9->VG9_CODMAR := cCodmar
VG9->VG9_RRCFAB := cNumRrc
VG9->VG9_NFALHA := left(cAnoRrc,2)
VG9->VG9_NRECON := right(cAnoRrc,2)
nKMGuin := nGuinA // VI1->VI1_VALPGT
nQtdGui := nGuinQA // VI1->VI1_QTDAPR
msunlock()


dbselectArea("VG8")
dbgotop()
dbsetorder(1)
if !dbseek(xFilial("VG8")+cCodMar+cNUMOSV+cANORRC+cNUMRRC)
	dbselectArea("VG8")
	dbgotop()
	dbsetorder(4)
	if !dbseek(xFilial("VG8")+cNUMRRC+cANORRC)
		Msgstop(STR0008 + cNUMOSV+ " RR " +cNUMRRC + " " + cANORRC + STR0009)
		lRet := .f.
		return
	endif
endif

nBxaPec := nValIte + nValDif + nValInd + nValMat + nValLub
nBxaSer := nValMaoSC + nValMaoTc + nKmPick + nValPer + nKmGuin

if cTipMov = "C"         //LIQUIDADA
	
	If !RecLock("VG8", !Found() )
		Help("  ",1,"REGNLOCK")
		lRet := .f.
		DisarmTransaction()
		Break
	EndIf
	VG8->VG8_NFCRED := cNFCred
	VG8->VG8_DATCRE := dDTCred
	VG8->VG8_KILPIC := nPickQA
	VG8->VG8_KILGUI := nGuinQA
	VG8->VG8_ITEPGT := nBxaPec
	VG8->VG8_SERPGT := nBxaSer
	VG8->VG8_SITRRC := "03"
	VG8->VG8_DESSIT := cASSUNT + " - " + cATENDI
	VG8->VG8_DATRET := dDatRet
	//	VG8->VG8_DATCRE := dDatRet
	MsUnlock()
	
elseif cTipMov = "D"     //ESTORNADA
	
	If !RecLock("VG8", !Found() )
		Help("  ",1,"REGNLOCK")
		lRet := .f.
		DisarmTransaction()
		Break
	EndIf
	
	VG8->VG8_ITEEST := nBxaPec
	VG8->VG8_SEREST := nBxaSer
	VG8->VG8_SITRRC := "04"
	VG8->VG8_DESSIT := cASSUNT + " - " + cATENDI
	VG8->VG8_DATRET := dDatRet
	VG8->VG8_DATEST := dDatRet
	MsUnlock()
	
elseif cTipMov = "R"    //POSSIVEL RECONSIDERACAO
	
	If !RecLock("VG8", !Found() )
		Help("  ",1,"REGNLOCK")
		lRet := .f.
		DisarmTransaction()
		Break
	EndIf
	
	VG8->VG8_DATRET := dDATRET
	VG8->VG8_SITRRC := "05"
	VG8->VG8_DESSIT := cASSUNT + OemtoAnsi(STR0005)
	MsUnlock()
	
endif

return


/*
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    �CPOIA040  � Autor �Renata                 � Data � 25/11/99 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o �Pega os campos no SX3 para serem mostrados na visualizacao  咳�
臼�          �                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe e � CPOIA040()                                                 咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Parametros�                                                            咳�
臼�          �                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Uso      � integracao                                                 咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function CPOIA040()

DbSelectArea("SX3")
dbgotop()
dbseek("VI102")
aCampos := {}

do While !eof() .and. x3_arquivo == "VI1"
	if X3USO(x3_usado) .And. cNivel>=x3_nivel   //.And. x3_campo $ [VI1_NUMOSV/VI1_NUMNFI/VI1_SERIEN/VI1_CHASSI/VI1_CODGAR/VI1_DESGAR/VI1_DESMAR/VI1_CODCLI/VI1_NOMCLI/VI1_ABEGAR/VI1_DATFEC/VI1_EXPGAR]
		aadd(aCampos,x3_campo)
	endif
	dbskip()
Enddo

DbSelectArea("VI1")

Return

/*
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    �FS_DELAIA40 Autor �Renata                 � Data � 25/11/99 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Apaga os dados do arquivo VI1                              咳�
臼�          �                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe e � FS_DELIA40()                                               咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Parametros�                                                            咳�
臼�          �                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Uso      � integracao                                                 咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function FS_DELIA40()


DbSelectArea("VI1")
//dbgotop()
DbSeek( xFilial("VI1") )

do while !VI1->(Eof()) .And. VI1->VI1_FILIAL == xFilial("VI1")
	
	RecLock("VI1",.F.,.T.)
	DBDelete()
	MsUnlock()
	
	DBSkip()
	
enddo


return
