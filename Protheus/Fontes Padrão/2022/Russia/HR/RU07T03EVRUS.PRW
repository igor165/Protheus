#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RU07T03EVRUS.CH'

//------------------------------------------------------------------
/*/{Protheus.doc} RU07T03EVRUS()
@description Event class for RU07T03

@author Flavio Lopes Rasta

@type Class
@since 13/04/2018
/*/
//-------------------------------------------------------------------
Class RU07T03EVRUS From FwModelEvent 
    
    Method New() CONSTRUCTOR
    Method InTTS()
	Method ModelPosVld()

    Method RecSRA()
	Method RecSR3SR7()
	Method RecSPF()	
	Method RecStation()
	Method RecSR9()

EndClass

//------------------------------------------------------------------
/*/{Protheus.doc} New()
@description Constructor for the class RU07T03EVRUS

@author Flavio Lopes Rasta

@type Class
@since 13/04/2018
/*/
//-------------------------------------------------------------------
Method New() Class RU07T03EVRUS
Return Nil

//------------------------------------------------------------------
/*/{Protheus.doc} InTTS()
@description Method that runs inside the trasaction.

@author Flavio Lopes Rasta

@type Class
@since 13/04/2018
/*/
//-------------------------------------------------------------------
Method InTTS(oModel, cModelId) Class RU07T03EVRUS

Local oModelTMP := oModel:GetModel("TMPDETAIL")

//Gravar SR9
::RecSR9(oModel)

//Gravar SR3/SR7
If 	!Empty(oModelTMP:GetValue("AMOUNT")) .Or.;
	!Empty(oModelTMP:GetValue("FUNCCAT")) .Or.;
	!Empty(oModelTMP:GetValue("PAYTYPE")) .Or.;
	!Empty(oModelTMP:GetValue("STATION")) .Or.;
	!Empty(oModelTMP:GetValue("DEPARTMENT"))

	::RecSR3SR7(oModel)
Endif
//Gravar SPF

If !Empty(oModelTMP:GetValue("WORKSHIFT")) .And.!Empty(oModelTMP:GetValue("WORKTMSCHD"))
	::RecSPF(oModel)	
Endif

//Gravar Movimento Station
If !Empty(oModelTMP:GetValue("STATION"))
	::RecStation(oModel)
EndIf

//Gravar SRA
::RecSRA(oModel)

Return 

//------------------------------------------------------------------
/*/{Protheus.doc} RecSR9()
@description Method that records the table SR9.

@author Flavio Lopes Rasta

@type Class
@since 13/04/2018
/*/
//-------------------------------------------------------------------
Method RecSR9(oModel) Class RU07T03EVRUS
Local nX 			as Numeric
Local oStruOPER 	as Object
Local oModelTMP		as Object
Local aRecFields 	as Array
Local aFields		as Array
Local aAreaSR9		as Array

aAreaSR9 := SR9->(GetArea())

oModelTMP	:= oModel:GetModel("TMPDETAIL")
oStruOPER	:= oModelTMP:GetStruct()
aFields		:= oStruOPER:GetFields()

aRecFields := {	{"REASON","REASON"},;
				{"SALTABLE","RA_TABELA"},;
				{"TABRANGE","RA_TABNIVE"},;
				{"TABLEVEL","RA_TABFAIX"},;
				{"AMOUNT","RA_SALARIO"},;
				{"FUNCCAT","RA_CATFUNC"},;
				{"PAYTYPE","RA_TIPOPGT"},;
				{"WORKSHIFT","RA_TNOTRAB"},;
				{"WORKTMSCHD","RA_SEQTURN"},;
				{"DEPARTMENT","RA_DEPTO"},;
				{"STATION","RA_POSTO"},;
				{"POSITION","RA_CARGO"},;
				{"ROLE","RA_CODFUNC"}}

For nX :=1 To Len(aFields)
	If (nPos:= aScan(aRecFields,{|x| x[1] == aFields[nX][3]})) > 0
		If !Empty(oModelTMP:GetValue(aFields[nX][3]))
			SR9->(DbSetOrder(2))
			If !SR9->(DbSeek(xFilial("SR9")+SRA->RA_MAT+aRecFields[nPos][2]))
				
				RecLock("SR9",.T.)

				SR9->R9_FILIAL	:= SRA->RA_FILIAL
				SR9->R9_MAT		:= SRA->RA_MAT	
				SR9->R9_DATA	:= SRA->RA_ADMISSA	
				SR9->R9_CAMPO	:= aRecFields[nPos][2]
				If aRecFields[nPos][2] == "REASON"
					SR9->R9_DESC	:= "00"
				Else
					SR9->R9_DESC	:= cValToChar(SRA->&(aRecFields[nPos][2]))	
				Endif
				SR9->(MSUnlock())
			Endif

			RecLock("SR9",.T.)

			SR9->R9_FILIAL	:= SRA->RA_FILIAL
			SR9->R9_MAT		:= SRA->RA_MAT	
			SR9->R9_DATA	:= dDataBase	
			SR9->R9_CAMPO	:= aRecFields[nPos][2]
			SR9->R9_DESC	:= cValToChar(oModelTMP:GetValue(aFields[nX][3]))	

			SR9->(MSUnlock())
		Endif
	EndIf
Next nX

RestArea(aAreaSR9)

Return 
//------------------------------------------------------------------
/*/{Protheus.doc} RecSR3SR7()
@description Method that records the tables SR3/SR7.

@author Flavio Lopes Rasta

@type Class
@since 13/04/2018
/*/
//-------------------------------------------------------------------
Method RecSR3SR7(oModel) Class RU07T03EVRUS
Local oModelTMP 	:= oModel:GetModel("TMPDETAIL")
Local aArea			:= GetArea() 
Local aR7AllRecs	:= {}
Local cDescCar 		:= ""   
Local cFun			:= ""   
Local lAchouAlt		:= .T.	 
Local nPosDt		:= 0
Local nPosTp		:= 0
Local nR7SeqTam	    
Local dRaDataAlt	:= STOD("//")
Local cTipAum		:= ""
Local cRole			:= ""
Local cPosition		:= ""

dRaDataAlt	:= dDataBase
cTipAum		:= oModelTMP:GetValue("REASON")

fSeqHistSal( @aR7AllRecs, @nR7SeqTam ) // Funcao para preenchimento dos campos R7_SEQ e R3_SEQ	

// Verifica se ja teve alguma alteracao salarial se nao grava a anterior como primeira
dbSelectArea("SR7")
If SR7->( !dbSeek(SRA->RA_FILIAL+SRA->RA_MAT) )

	cFun := DescFun( SRA->RA_CODFUNC , SRA->RA_FILIAL )

	If SQ3->( dbSeek(xFilial("SQ3")+SRA->RA_CARGO+SRA->RA_CC)) .Or. SQ3->( dbSeek(xFilial("SQ3")+SRA->RA_CARGO))
		cDescCar := SQ3->Q3_DESCSUM
	EndIf
	// Grava o Salario anterior quando nao existir alteracao
	dbSelectArea("SR7")
	If SR7->( RecLock("SR7",.T.,.T.) )
			SR7->R7_FILIAL   := SRA->RA_FILIAL
			SR7->R7_MAT      := SRA->RA_MAT
			SR7->R7_DATA     := SRA->RA_ADMISSA
			SR7->R7_TIPO     := "00"
			SR7->R7_FUNCAO   := SRA->RA_CODFUNC
			SR7->R7_DESCFUN  := cFun
			SR7->R7_TIPOPGT  := SRA->RA_TIPOPGT
			SR7->R7_CATFUNC  := SRA->RA_CATFUNC
			SR7->R7_USUARIO  := OemToAnsi("STR0001") // "System"
	
			If SR7->( Type("R7_CARGO") ) # "U"
				SR7->R7_CARGO   := SRA->RA_CARGO
			EndIf
			If SR7->( Type("R7_DESCCAR") ) # "U"
				SR7->R7_DESCCAR	:= cDescCar
			EndIf
			If SR7->( Type("R7_SEQ") ) # "U" .And. ValType(nR7SeqTam) == "N"
				SR7->R7_SEQ		:= Strzero( 1, nR7SeqTam )
			EndIf
			
		SR7->( MsUnLock() )
	EndIf	

	dbSelectArea("SR3")
	If	RecLock("SR3",.T.,.T.)
	
			SR3->R3_FILIAL   := SRA->RA_FILIAL
			SR3->R3_MAT      := SRA->RA_MAT
			SR3->R3_DATA     := SRA->RA_ADMISSA
			SR3->R3_PD       := "000"
			SR3->R3_DESCPD   := OemToAnsi(STR0002)  //"BASE SALARY"
			SR3->R3_VALOR    := SRA->RA_SALARIO
			SR3->R3_TIPO     := "001"
	
			If SR3->( Type("R3_SEQ") ) # "U" .And. ValType(nR7SeqTam) == "N"
				SR3->R3_SEQ		:= Strzero( 1, nR7SeqTam )
			EndIf

		SR3->( MsUnLock() )
	EndIf	
EndIf

// Gravacao da alteracao salarial atual
cFun := DescFun(oModelTMP:GetValue("ROLE"))

If SQ3->( dbSeek(xFilial("SQ3")+oModelTMP:GetValue("POSITION")))
	cDescCar := SQ3->Q3_DESCSUM
EndIf

dbSelectArea("SR7")

If dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+Dtos(dRaDataAlt)+cTipAum )
	RecLock("SR7",.F.,.T.)
Else
	RecLock("SR7",.T.,.T.) 
	lAchouAlt := .F.
EndIf

SR7->R7_FILIAL   := SRA->RA_FILIAL
SR7->R7_MAT      := SRA->RA_MAT
SR7->R7_DATA     := dRaDataAlt
SR7->R7_TIPO     := cTipAum
SR7->R7_FUNCAO   := If(!Empty(oModelTMP:GetValue("ROLE")),oModelTMP:GetValue("ROLE"),SRA->RA_CODFUNC)
SR7->R7_DESCFUN  := cFun
SR7->R7_TIPOPGT  := If(!Empty(oModelTMP:GetValue("PAYTYPE")),oModelTMP:GetValue("PAYTYPE"),SRA->RA_TIPOPGT)
SR7->R7_CATFUNC  := If(!Empty(oModelTMP:GetValue("FUNCCAT")),oModelTMP:GetValue("FUNCCAT"),SRA->RA_CATFUNC)
SR7->R7_USUARIO  := SubStr(cUsuario,7,15)

If SR7->( Type("R7_CARGO") ) # "U"
	SR7->R7_CARGO   := oModelTMP:GetValue("POSITION")
EndIf

If SR7->( Type("R7_DESCCAR") ) # "U"
	SR7->R7_DESCCAR	:= cDescCar
EndIf

If SR7->( Type("R7_SEQ") ) # "U"

	If Len( aR7AllRecs ) > 0 .And. ( ( nPosDt := aScan( aR7AllRecs, { |x| x[ 1 ] == SR7->R7_DATA } ) ) > 0 ) // Existe alteracao salarial para a data informada
	
			If lAchouAlt // Mesmo tipo de aumento, entao localiza seq. e substitui
					
				nPosTp 	:= aScan( aR7AllRecs[ nPosDt, 2 ], { |x| x[ 2 ] == SR7->R7_TIPO } ) // Localiza registro do mesmo tipo de aumento
				SR7->R7_SEQ	:= aR7AllRecs[ nPosDt, 2, nPosTp, 3 ]
			Else // Tipo de aumento diferente, entao atualiza seq. como sendo a ultima
					
				aSort( @aR7AllRecs[ nPosDt, 2 ], , , { | x, y | x[ 3 ] < y[ 3 ] } )
				SR7->R7_SEQ	:= StrZero( Val( Soma1( aR7AllRecs[ nPosDt, 2, Len( aR7AllRecs[ nPosDt, 2 ] ), 3 ] ) ), nR7SeqTam )
			EndIf
		
	Else // Nao existem quaisquer alteracoes salariais p/ a data informada, logo eh a primeira seq.						
		If( ValType(nR7SeqTam) == "N", SR7->R7_SEQ := StrZero( 1, nR7SeqTam ), )
	EndIf
Endif

SR7->( MsUnLock() )

DbSelectArea("SR3")

If DbSeek(SRA->RA_FILIAL+SRA->RA_MAT+Dtos(dRaDataAlt)+cTipAum )
	RecLock("SR3",.F.,.T.)
Else
	RecLock("SR3",.T.,.T.)
EndIf

SR3->R3_FILIAL   := SRA->RA_FILIAL
SR3->R3_MAT      := SRA->RA_MAT
SR3->R3_DATA     := dRaDataAlt
SR3->R3_PD       := "000"
SR3->R3_DESCPD   := OemToAnsi("SALARIO BASE")  //"SALARIO BASE"   
SR3->R3_VALOR    := If(!Empty(oModelTMP:GetValue("AMOUNT")),oModelTMP:GetValue("AMOUNT"),SRA->RA_SALARIO)
SR3->R3_TIPO     := cTipAum     

If SR3->( Type("R3_SEQ") ) # "U"
	SR3->R3_SEQ		:= SR7->R7_SEQ
EndIf
SR3->( MsUnLock() )

PcoDetLan('000084','04','GPEA010')	

RestArea( aArea )

Return( Nil )

//------------------------------------------------------------------
/*/{Protheus.doc} RecSPF()
@description Method that records the table SPF.

@author Flavio Lopes Rasta

@type Class
@since 13/04/2018
/*/
//-------------------------------------------------------------------

Method RecSPF(oModel)  Class RU07T03EVRUS
Local oModelTMP as Object
Local cFil 		as Character
Local cMat 		as Character
Local lSeek		as Logical
Local aAreaSPF	as Array

aAreaSPF := SPF->(GetArea())
oModelTMP := oModel:GetModel("TMPDETAIL")

cFil := SRA->RA_FILIAL
cMat := SRA->RA_MAT

SPF->(DbSetOrder(1))
lSeek := SPF->( MsSeek( xFilial("SPF",cFil) + cMat + Dtos(dDataBase) , .F. ) ) 

RecLock( "SPF" , !lSeek )

SPF->PF_FILIAL	:= xFilial( "SPF" , cFil )
SPF->PF_MAT		:= cMat
SPF->PF_DATA	:= dDataBase
SPF->PF_TURNODE	:= SRA->RA_TNOTRAB
SPF->PF_SEQUEDE := SRA->RA_SEQTURN
SPF->PF_TURNOPA	:= oModelTMP:GetValue("WORKSHIFT")
SPF->PF_SEQUEPA := oModelTMP:GetValue("WORKTMSCHD")
SPF->PF_REASC	:= oModelTMP:GetValue("REASON")
SPF->PF_SEQUEPA := oModelTMP:GetValue("WORKTMSCHD")

SPF->(MsUnlock())

RestArea(aAreaSPF)

Return

//------------------------------------------------------------------
/*/{Protheus.doc} RecStation()
@description Method that records the table SPF.

@author Flavio Lopes Rasta

@type Class
@since 13/04/2018
/*/
//-------------------------------------------------------------------
Method RecStation(oModel)  Class RU07T03EVRUS
Local oModelTMP as Object
Local cOrgCfg	as Character
Local cFilFrom	as Character
Local cStatFrom	as Character
Local cRegister	as Character
Local cFilTo	as Character
Local cStatTo	as Character

oModelTMP := oModel:GetModel("TMPDETAIL")
cOrgCfg := GetMv("MV_ORGCFG", NIL, "0")

cFilFrom	:= SRA->RA_FILIAL
cStatFrom	:= SRA->RA_POSTO
cRegister	:= SRA->RA_MAT

cFilTo		:= SRA->RA_FILIAL
cStatTo		:= oModelTMP:GetValue("STATION")

If (cOrgCfg == "1") .AND. (cFilFrom+cStatFrom != cFilTo+cStatTo)
	OrgXRescisao(cFilFrom, cRegister, dDataBase)
	OrgXOcupacao(cFilTo, cRegister, cStatTo, dDataBase)
EndIf	

Return

//------------------------------------------------------------------
/*/{Protheus.doc} RecSRA()
@description Method to record the table SRA

@author Flavio Lopes Rasta

@type Class
@since 13/04/2018
/*/
//-------------------------------------------------------------------

Method RecSRA(oModel) Class RU07T03EVRUS

Local oModelTMP := oModel:GetModel("TMPDETAIL")
Local nHrsDia	:= 0
Local lGrvHrs	:= .F.

If !Empty(oModelTMP:GetValue("WORKSHIFT"))
	SR6->(DbSetOrder(1))
	If SR6->(DbSeek(xFilial("SR6")+oModelTMP:GetValue("WORKSHIFT")))
		lGrvHrs := .T.
		nHrsDia := SR6->R6_HRDIA 
	Endif
Endif

RecLock("SRA",.F.)

SRA->RA_TABELA   := If(!Empty(oModelTMP:GetValue("SALTABLE")),oModelTMP:GetValue("SALTABLE"),SRA->RA_TABELA)
SRA->RA_TABFAIX  := If(!Empty(oModelTMP:GetValue("TABRANGE")),oModelTMP:GetValue("TABRANGE"),SRA->RA_TABFAIX)
SRA->RA_TABNIVE  := If(!Empty(oModelTMP:GetValue("TABLEVEL")),oModelTMP:GetValue("TABLEVEL"),SRA->RA_TABNIVE)
SRA->RA_SALARIO  := If(!Empty(oModelTMP:GetValue("AMOUNT")),oModelTMP:GetValue("AMOUNT"),SRA->RA_SALARIO)
SRA->RA_TNOTRAB  := If(!Empty(oModelTMP:GetValue("WORKSHIFT")),oModelTMP:GetValue("WORKSHIFT"),SRA->RA_TNOTRAB)
SRA->RA_SEQTURN  := If(!Empty(oModelTMP:GetValue("WORKTMSCHD")),oModelTMP:GetValue("WORKTMSCHD"),SRA->RA_SEQTURN)
SRA->RA_DEPTO    := If(!Empty(oModelTMP:GetValue("DEPARTMENT")),oModelTMP:GetValue("DEPARTMENT"),SRA->RA_DEPTO)
SRA->RA_CARGO    := If(!Empty(oModelTMP:GetValue("POSITION")),oModelTMP:GetValue("POSITION"),SRA->RA_CARGO)
SRA->RA_CODFUNC  := If(!Empty(oModelTMP:GetValue("ROLE")),oModelTMP:GetValue("ROLE"),SRA->RA_CODFUNC)
SRA->RA_POSTO    := If(!Empty(oModelTMP:GetValue("STATION")),oModelTMP:GetValue("STATION"),SRA->RA_POSTO)

If lGrvHrs
	SRA->RA_HRSDIA := nHrsDia
EndIf

SRA->(MsUnlock())

Return .T.


//------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld()
@description Method to validate the model before commit

@author Flavio Lopes Rasta

@type Class
@since 13/04/2018
/*/
//-------------------------------------------------------------------
Method ModelPosVld(oModel, oModelId)  Class RU07T03EVRUS
Local lRet			as Logical
Local oModelTMP		as Object
Local aFields		as Array
Local nX 			as Numeric

aFields := {	"SALTABLE",;
				"TABRANGE",;
				"TABLEVEL",;
				"AMOUNT",;
				"FUNCCAT",;
				"PAYTYPE",;
				"WORKSHIFT",;
				"WORKTMSCHD",;
				"DEPARTMENT",;
				"STATION"}

oModelTMP := oModel:GetModel("TMPDETAIL")

For nX:=1 To Len(aFields)
	If !Empty(oModelTMP:GetValue(aFields[nX]))
		lRet := .T.
		Exit
	Else
		lRet := .F.
	Endif
Next nX
If !lRet
	Help('',1,'RU07T03NOOPE',,STR0003,1) //"It is necessary to do at least one operation!"
Endif

If lRet
	If !Empty(oModelTMP:GetValue("DEPARTMENT"))
		If Empty(oModelTMP:GetValue("STATION"))
			lRet := .F.
			Help('',1,'RU07T03FLSTAT',,STR0004,1) //"It is necessary to fill the field Station!"
		Endif
	Endif
EndIf

Return lRet
// Russia_R5
