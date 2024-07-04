#INCLUDE "FISA821.ch"   
#INCLUDE "Protheus.ch"   
#INCLUDE "TopConn.ch"
#INCLUDE "REPORT.CH"

#DEFINE _BUFFER 16384
#DEFINE _SEPARADOR ";"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FISA821  ³ Autor ³ Laura Elena Medina  ³ Data ³ 14/01/2019 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Procesa a partir de un arquivo CSV gerado y disponibilizado³±±
±±³          ³ por la dependencia, el archivo contiene el % percepcion y  ³±±
±±³          ³ % Retencion para mantenimiento de la tabla SFH.            ³±±
±±³          ³ RG 15-16 - Municipalidad La Plata - Padrón Alícuotas Reten-³±±
±±³          ³ ción y Percepción.                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³ Uso      ³ Fiscal - Municipalidad "La Plata" - Argentina              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±   
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/   

Function FISA821()
Local   cCombo 	:= ""
Local   aCombo 	:= {}
Local   oDlg   	:= Nil
Local   oFld   	:= Nil
Local  oCombo   := Nil
Private lCuitSM0:= .F.
Private dDatIni := CTOD("  /  /  ") // Data inicial do periodo enviada no XLS
Private dDatFim := CTOD("  /  /  ") // Data final do periodo enviada no XLS
Private oTmpTable := Nil
Private lAct	:= .F.
Private cImpPLP := "PLP"
Private cImpRLP := "RLP"
Private lAduana := .F.

aAdd( aCombo, STR0002 ) //"1- Fornecedor"
aAdd( aCombo, STR0003 ) //"2- Cliente"
aAdd( aCombo, STR0004 ) //"3- Ambos"

DEFINE MSDIALOG oDlg TITLE STR0001 FROM 0,0 TO 300,450 OF oDlg PIXEL //"RG 15-16 – Municipalidad de La Plata – Padrón de Alicuotas de Retención y Percepción."
	 
	@ 006,006 TO 040,170 LABEL STR0007 OF oDlg PIXEL //"Info. Preliminar"
	@ 015,010 COMBOBOX oCombo VAR cCombo ITEMS aCombo SIZE 65,8 PIXEL OF oFld //ON CHANGE ValidChk(cCombo)
	
	//+----------------------   
	//| Archivo
	//+----------------------
	@ 041,006 FOLDER oFld OF oDlg PROMPT STR0008 PIXEL SIZE 175,100 //"&Importação de Arquivo CSV"
	
	//+----------------
	//| Campos Folder 2
	//+----------------
	@ 005,005 SAY STR0009 SIZE 165,008 PIXEL OF oFld:aDialogs[1] //"Esta opción tiene como objetivo importar el archivo CSV Proveedor"
	@ 015,005 SAY STR0010 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"/ Cliente para la RG 15-16 – Municipalidad de La Plata - Padrón"
	@ 025,005 SAY STR0011 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"de Alicuotas de Retención y Percepción, puesto a disposición."                      "
	@ 045,005 SAY STR0005 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Fecha Inicio Vigencia"    
	@ 045,065 MSGET dDatIni  VALID VldDatas(1,.F.,"") SIZE  040,008 PIXEL OF oFld:aDialogs[1]	                                          
	@ 058,005 SAY STR0006 SIZE 150,008 PIXEL OF oFld:aDialogs[1] // "Fecha Fin Vigencia"  
	@ 058,065 MSGET dDatFim  VALID VldDatas(2,.F.,"") SIZE 040,008 PIXEL OF oFld:aDialogs[1]
	
	//+-------------------
	//| Boton de MSDialog
	//+-------------------
	@ 055,185 BUTTON STR0015 SIZE 036,016 PIXEL ACTION ImpArq(cCombo) //"&Importar"
	@ 075,185 BUTTON STR0016 SIZE 036,016 PIXEL ACTION oDlg:End() //"&Sair"

ACTIVATE MSDIALOG oDlg CENTER

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ImpArq   ³ Autor ³ TOTVS               ³ Data ³ 15/01/2019 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inicializa a importacao do arquivo.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCombo - Variable con las opcoes: Cliente/Proveedor/Ambos. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpArq(cCombo)
Local aArqTmp	:= {}	// Arquivo temporario para importacao
Local lRet	 	:= .T.
Private  cFile  := ""

//Validación de las fechas de acuerdo a la especificación
If  !VldDatas(3,.T.,"")
	Return Nil
Endif

lAct :=.F.

// Seleciona el archivo
cFile := FGetFile()
If  Empty(cFile)
	Return Nil
ElseIf  !VldDatas(3,.T.,cFile) //Se debe verificar el nombre del archivo 
	Return Nil
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gera arquivo temporario a partir do XLS importado  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Processa({|| lRet := GeraTemp(@aArqTmp)})

If lRet
	If  SubStr(cCombo,1,1) $ "1|3"// Fornecedor-SM0 ou Ambos
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Processo de valiadacao para Fornecedores ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Processa({|| ProcCliFor("SA2")})
	EndIf
	If SubStr(cCombo,1,1) $ "2|3" // Cliente ou Ambos
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Processo de valiadacao para Clientes ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Processa({|| ProcCliFor("SA1")})
	EndIf
	If  lAct
		AVISO(STR0012,STR0025,{STR0013}) //Atención,"Proceso finalizado con éxito!",{Ok}
	Else
		AVISO(STR0012,STR0026,{STR0013}) //Atención,"No hubo actualizaciones durante el proceso.",{Ok}
	EndIf
Endif

TMP->(dbCloseArea())
If oTmpTable <> Nil
	oTmpTable:Delete()
	oTmpTable := Nil
EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FGetFile ³ Autor ³ TOTVS               ³ Data ³ 14/01/2019 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela de seleccion de archivo CSV a ser importado.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cRet - Diretorio y archivo seleccionado.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FGetFile()
Local cRet := Space(200)
	
oDlg01 := MSDialog():New(000,000,100,500,STR0017,,,,,,,,,.T.)//"Selecionar arquivo"
	
oGet01 := TGet():New(010,010,{|u| If(PCount()>0,cRet:=u,cRet)},oDlg01,215,10,,,,,,,,.T.,,,,,,,,,,"cRet")
oBtn01 := TBtnBmp2():New(017,458,025,028,"folder6","folder6",,,{|| FGetDir(oGet01)},oDlg01,STR0017,,.T.)//"Selecionar arquivo"
	
oBtn02 := SButton():New(035,185,1,{|| oDlg01:End() }         ,oDlg01,.T.,,)
oBtn03 := SButton():New(035,215,2,{|| cRet:="",oDlg01:End() },oDlg01,.T.,,)
	
oDlg01:Activate(,,,.T.,,,)

Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FGetDir  ³ Autor ³ TOTVS               ³ Data ³ 14/01/2019 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela para buscar/seleccionar el archivo en los directorios ³±±
±±³          ³ local/servidor/unidades mapeadas.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oTGet - Objeto TGet que ira receber o local e o arquivo    ³±±
±±³          ³         selecionado.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FGetDir(oTGet)

Local cDir := ""
	
cDir := cGetFile(,STR0017,,,.T.,GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE)//"Selecionar arquivo"
If !Empty(cDir)
	oTGet:cText := cDir
	oTGet:Refresh()
Endif
oTGet:SetFocus()

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VldDatas ³ Autor ³ TOTVS               ³ Data ³ 14/01/2018 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validación de la Fecha Inicio/Fin Vigencia                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nDatVig - 1 Fecha Vigencia Inicial y 2 Fecha Vigencia Fin  ³±±
±±³          ³ lBoton - .T. Al confirmar                                  ³±±
±±³          ³ cArquivo - Ruta y nombre del archivo a procesar            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Buenos Aires Argentina                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function VldDatas(nDatVig,lBoton,cArquivo) 
Local lRet := .T. 
Default nDatVig := 3 //3 - No procesa nada 
Default lBoton := .F.
Default cArquivo:= ""

If  lBoton
	If  Empty(dDatIni) .OR. Empty(dDatFim)
		AVISO(STR0012,STR0028,{STR0013}) //Atención,"Se deben informar las Fechas Inicio y Fin Vigencia",{Ok}
		lRet := .F.
	ElseIf  (StrZero(Month(dDatIni),2) != StrZero(Month(dDatFim),2))  .OR.  (StrZero(Year(dDatIni),4) != StrZero(Year(dDatFim),4))
		AVISO(STR0012,STR0029,{STR0013}) //Atención,"Las Fechas Inicio y Fin Vigencia deben ser informadas en el mismo mes y año.",{Ok}
		lRet := .F.
	Endif
	If  lRet .And. !Empty(cArquivo)  //Verificar que el nombre del archivo contenga las mismas fechas de inicio y Fin de Vigencia		
		If  AT(StrZero(Year(dDatIni),4)+StrZero(Month(dDatIni),2), Substr(cArquivo,RAT("\",cArquivo)+1,( len(cArquivo)- RAT("\",cArquivo)) ) ) <=0
			AVISO(STR0012,STR0019 + Alltrim(Substr(cArquivo,RAT("\",cArquivo)+1,(len(cArquivo)- RAT("\",cArquivo)) )) +;
			STR0030 + STR0031,{STR0013}) //"El Archivo: " + XXX + " debe corresponder con el mes y año indicados en la Fecha Inicio Vigencia y Fecha Fin Vigencia. Indique un nombre de arcuivo válido."
			lRet = .F.
		Endif
	Endif
Elseif nDatVig == 1 
	If  Empty(dDatIni)
		AVISO(STR0012,STR0032,{STR0013}) //"Se debe informar una Fecha Inicio Vigencia."
		//lRet := .F.
	Else
		If !Empty(dDatFim) 
			If  dDatIni>dDatFim
				AVISO(STR0012,STR0033,{STR0013}) //"La Fecha Inicio Vigencia debe ser menor a la Fecha Fin Vigencia."
				lRet := .F.
			Endif
		Endif
	Endif
Elseif nDatVig == 2
	If  Empty(dDatFim)
		AVISO(STR0012,STR0034,{STR0013}) //"Se debe informar una Fecha Fin Vigencia."
		//lRet := .F.
	Else
		If !Empty(dDatIni) 
			If  dDatIni>dDatFim
				AVISO(STR0012,STR0035,{STR0013}) //"La Fecha Fin Vigencia debe ser mayor a la Fecha Inicial Vigencia."
				lRet := .F.
			Endif
		Endif
	Endif
Endif


Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³GeraTemp     ³ Autor ³ TOTVS              ³ Data ³15/01/2019³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Gera arquivo temporario a partir do XLS importado           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³GeraTemp(aArqTmp)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Especifico FISA821                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/          
Static Function GeraTemp(aArqTmp)
Local aInforma   := {} 		// Array auxiliar com as informacoes da linha lida no arquivo XLS
Local aCampos    := {}		// Array auxiliar para criacao do arquivo temporario
Local cArqProc   := cFile	// Arquivo a ser importado selecionado na tela de Wizard
Local cErro	     := ""		// Texto de mensagem de erro ocorrido na validacao do arquivo a ser importado
Local cSolucao   := ""		// Texto de solucao proposta em relacao a algum erro ocorrido na validacao do arquivo a ser importado
Local lArqValido := .T.		// Determina se o arquivo XLS esta ok para importacao
Local nHandle    := 0		// Numero de referencia atribuido na abertura do arquivo XLS
Local cMsg		 := STR0018 //"Leyendo archivo. Espere..."  
Local nI 		 := 0
Local oFile
Local nFor		 := 0
Local cBuffer    := ""
Local aArea      := ""
Local cTitulo	 := STR0014  //"Problemas en la importación del archivo"
Local lRet       := .T.		// Determina a continuidade do processamento como base nas informacoes da tela de Wizard 						

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria o arquivo temporario para a importacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//*************Modelo do arquivo*************
//ID;    Version;Cod.Tasa;CUIT;        %Perc;%Reten; <--En Miles
//256501;  1.0.9;       5;27224772381;     5;     5;
AADD(aCampos,{"CUIT"	  ,"C",TamSX3("A2_CGC")[1],0})
AADD(aCampos,{"ALIQPER"	  ,"N",TamSX3("FH_ALIQ")[1],2})
AADD(aCampos,{"ALIQRET"	  ,"N",TamSX3("FH_ALIQ")[1],2})

oTmpTable := FWTemporaryTable():New("TMP")
oTmpTable:SetFields( aCampos )
aOrdem	:=	{"CUIT"}

oTmpTable:AddIndex("TMP", aOrdem)
oTmpTable:Create() 

If File(cArqProc) .And. lRet

	nHandle := FT_FUse(cArqProc)
	
	If  nHandle > 0 
		//Se posiciona en la primera línea
		FT_FGoTop()
		nFor := FT_FLastRec()	
		FT_FUSE()	
	Else
		lArqValido := .F.	
		cErro	   := STR0019 + cArqProc + STR0020	//"El archivo " +cArqProc+ "No puede abrirse"
		cSolucao   := STR0021 			//"Verifique si se informó el archivo correcto para importación"
	EndIf

	If lArqValido 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Gera arquivo temporario a partir do arquivo XLS ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oFile := FWFileReader():New(cArqProc)
		// Se hay error al abrir el archivo
		If !oFile:Open()
			MsgAlert(STR0019 + cArqProc + STR0020)  //"El archivo " +cArqProc+ "No puede abrirse"
			Return .F.
		EndIf
		
		ProcRegua(nFor)
		oFile:setBufferSize(_BUFFER)
		
		While (!oFile:Eof())
		 	nI++
		 	IncProc(cMsg + str(nI))	        

			cBuffer := oFile:GetLine()
			cBuffer := Alltrim(cBuffer)
		
			aInforma := {} 
			aInforma := separa(cBuffer,_SEPARADOR)
				
        	TMP->( DBAppend(.F.) )
  	  		TMP->CUIT	:= aInforma[4] 
  	  		TMP->ALIQPER:= Val(aInforma[5])/10
  	  		TMP->ALIQRET:= Val(aInforma[6])/10
			TMP->( DBCommit() )			
		Enddo
	Endif
	TMP->(dbGoTop())		
	
	oFile:Close()	 // Fecha o Arquivo

	If Empty(cErro) .and. TMP->(LastRec())==0     
		cErro		:= STR0022	//"La importación no se realizó por no existir información en el archivo informado."
		cSolucao	:= STR0021	//"Verifique se foi informado o arquivo correto para importação"
	Endif	
Else
	cErro	   := STR0019 + cArqProc + STR0020	//"El archivo " +cArqProc+ "No puede abrirse"
	cSolucao   := STR0021 						//"Verifique se foi informado o arquivo correto para importação"
EndIf
	 
If !Empty(cErro)
	xMagHelpFis(cTitulo,cErro,cSolucao)
	lRet := .F.
Endif

//Se realiza la busqueda por CUIT en la tabla Temporal 
aArea := GetArea()
TMP->(dbSetOrder(1))
If TMP->(MsSeek(AllTrim(SM0->M0_CGC)))
    lCuitSM0 := .T.	  					
EndIf
RestArea(aArea)

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcCliFor³ Autor ³ TOTVS                 ³ Data ³ 19/09/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa os arquivos de clientes/fornecedores para          ³±±
±±³          ³aplicacao das regras de validacao para agente retenedor     ³±±
±±³          ³em relacao ao arquivo enviado                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ProcCliFor(ExpC1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 = Alias da tabela a ser processada(SA1/SA2)           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Especifico - FISA135                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ProcCliFor(cAlias)
Local aArea     := GetArea()			// Salva area atual para posterior restauracao
Local lCli      := (cAlias=="SA1")		// Determina se la rotina fue llamada para processar clientes o Proveedores.
Local cPrefTab  := Substr(cAlias,2,2)	// Prefixo para acesso dos campos
Local cOrigen	:= IIf(lCli,"C","P")    // C=Cliente y P=Proveedor
Local nI 		:= 0

dbSelectArea(cAlias)
(cAlias)->(dbSetOrder(3))
(cAlias)->(dbGoTop())
    
ProcRegua(RecCount())
IncProc(Iif(lCli,STR0023,STR0024))	//"Procesando Clientes"..."Procesando Proveedores"

lAduana := .F.
If !lCli
	lAduana := VerifImp()
Endif

While (cAlias)->(!Eof())
	nI++
	IncProc(Iif(lCli,STR0023,STR0024) + Str(nI)) //"Procesando Clientes"..."Procesando Proveedores"
	
	IF  !lCli .And. lAduana  //Verificar si A2_TIPO = A (Aduana)
		If  (cAlias)->&(cPrefTab+"_TIPO") == "A"
			(cAlias)->(dbSkip())
		Endif
	Endif
	
	//Validar solamente los Clientes/Proveedores que tengan informado un CUIT		
	If  Empty((cAlias)->&(cPrefTab+"_CGC"))  
		(cAlias)->(dbSkip())
	EndIf
	If  "1183" $ (cAlias)->&(cPrefTab+"_COD") //LEMP TEMPORAL  
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Verifica se o cliente/fornecedor consta no arquivo temporario - ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  TMP->(MsSeek((cAlias)->&(cPrefTab+"_CGC")))  //Es Cliente-Proveedor y SI se encuentra en el padron.
		BuscaSFH(cAlias,lCli,cOrigen,.T.)		
	Else                                             //Es Cliente-Proveedor y NO se encuentra en el padron. 
		BuscaSFH(cAlias,lCli,cOrigen,.F.)		
	EndIf
	If  !lCli //Es Proveedor-SM0 (Percepciones)
		BuscaSFH(cAlias,lCli,"E",lCuitSM0)
	Endif
	Endif
	(cAlias)->(dbSkip())
EndDo


RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³BuscaSFH  ³Autor  ³ TOTVS               ³Data  ³02/01/2019  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Busca y actualiza registros en SFH 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias - Tabla temp con los registros obtenidos de SA1/SA2  ³±±
±±³          ³lCli   - Si .T. est?procesando Clientes					  ³±±
±±³          ³			Si .F. est?procesandoProveedores				  ³±±
±±³          ³lExiste- Si .T. se encuentra CUIT de Cliente/Prov en 	      ³±±
±±³          ³			archivo ASCII 									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nulo                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Fiscal - Argentina 			                  			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function BuscaSFH(cAlias,lCli,cOrigen,lPadron)  //SA1, .T., C, .T.
Local aArea		:= GetArea()
Local cQuery	:= ""	
Local cSFH		:= InitSqlName("SFH")
Local cTmp		:= GetNextAlias()                                
Local cPref		:= IIf(lCli,"A1","A2")
Local cTipo     := "I"
Local cSituaca  := "1"
Local nCont     := 0

//Seleccionar cliente o proveedor de SFH  
cQuery := "SELECT * "
cQuery += "FROM "
cQuery +=	cSFH + " SFH " 
cQuery += 	"WHERE " 
cQuery += 	"FH_FILIAL ='" + xFilial("SFH") + "' AND "
If  lCli	
	cQuery +=  	"FH_CLIENTE='" + (cAlias)->A1_COD	  	+ "' AND "
	cQuery += 	"FH_LOJA   ='" + (cAlias)->A1_LOJA   	+ "' AND "
Else       
	cQuery +=  	"FH_FORNECE='" + (cAlias)->A2_COD		+ "' AND "
	cQuery += 	"FH_LOJA   ='" + (cAlias)->A2_LOJA   	+ "' AND "
EndIf
If  cOrigen== "C" .OR. cOrigen== "E" 
	cQuery += "FH_IMPOSTO = '"+ cImpPLP +"' AND "
ElseIF cOrigen== "P" 
	cQuery += "FH_IMPOSTO = '"+ cImpRLP +"' AND "
Endif
cQuery += "FH_ZONFIS  = 'BA'  AND " 
cQuery += "D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY "//FH_FIMVIGE DESC, FH_INIVIGE DESC"
cQuery += "FH_INIVIGE DESC " 

cQuery := ChangeQuery(cQuery)                    
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.) 
TcSetField( cTmp,"FH_FIMVIGE","D", TamSX3("FH_FIMVIGE")[1], 0 )
TcSetField( cTmp,"FH_INIVIGE","D", TamSX3("FH_INIVIGE")[1], 0 )

Count to nCont
(cTmp)->(dbGoTop())
	
If  nCont > 0 //Actualizar registro
	If  lPadron   //(lCli .OR. (!lCli .AND. cOrigen== "E") .OR. (cOrigen =="P") ) 	
		If ((cTmp)->FH_ALIQ == IIf(lCli .OR. (!lCli .AND. cOrigen== "E"),TMP->ALIQPER,TMP->ALIQRET)  )	 //Cli-Per:Punto 1. a)-1- y Prov-Per:Punto 1. a)-1- y Prov-Ret:Punto 1. a)-1-
			SFH->(DBGOTO((cTmp)->R_E_C_N_O_))
			Reclock("SFH",.F.)
			SFH->FH_FIMVIGE := dDatFim  
			SFH->(MsUnlock())
			lAct := .T.
		Else	
			If  lCli //Cli-Per:Punto 1. a)-2- 
				IF  NaoExiste(.T.,(cAlias)->A1_COD,(cAlias)->A1_LOJA,(cTmp)->FH_IMPOSTO,TMP->ALIQPER)
					NewReg((cTmp)->FH_AGENTE,(cAlias)->A1_COD,"",(cAlias)->A1_LOJA,(cAlias)->&(cPref+"_NOME"),cTipo,(cTmp)->FH_PERCIBI,(cTmp)->FH_IMPOSTO,TMP->ALIQPER,        "N",(cTmp)->FH_APERIB,(cTmp)->FH_SITUACA,dDatIni,dDatFim)
					lAct := .T.
				Endif	
			Else     //Prov-Per:Punto 1. a)-2- y Prov-Ret:Punto 1. a)-2-
				If  NaoExiste(.F.,(cAlias)->A2_COD,(cAlias)->A2_LOJA,(cTmp)->FH_IMPOSTO,Iif(cOrigen =="P",TMP->ALIQRET,TMP->ALIQPER))
					NewReg((cTmp)->FH_AGENTE,"",(cAlias)->A2_COD,(cAlias)->A2_LOJA,(cAlias)->&(cPref+"_NOME"),cTipo,(cTmp)->FH_PERCIBI,(cTmp)->FH_IMPOSTO,Iif(cOrigen =="P",TMP->ALIQRET,TMP->ALIQPER) ,"N",(cTmp)->FH_APERIB,(cTmp)->FH_SITUACA,dDatIni,dDatFim)
					lAct := .T.
				Endif
			EndIf			
		EndIf
	Else
		If  lCli
			If  (cTmp)->FH_FIMVIGE > dDatIni  //Cli-Per: Punto 2. c)  y Cli-Per: Punto 2. d) 
				SFH->(DBGOTO((cTmp)->R_E_C_N_O_))
				Reclock("SFH",.F.)
				SFH->FH_FIMVIGE := dDatIni  
				SFH->(MsUnlock())
				lAct := .T.
			Endif
		ElseIf (!lCli .AND. cOrigen== "E") .Or. (cOrigen== "P") //Prov-Per: Punto 2. a)  y  Prov-Ret: Punto 2. a)
			If  !((cTmp)->FH_FIMVIGE < dDatIni) .OR.  Empty((cTmp)->FH_FIMVIGE )
				SFH->(DBGOTO((cTmp)->R_E_C_N_O_))
				Reclock("SFH",.F.)
				SFH->FH_FIMVIGE := dDatIni  
				SFH->(MsUnlock())
				lAct := .T.
			Endif
		Endif
	Endif
Else
	If  lPadron 
		If  cOrigen == "C" //Cli-Per: Punto 1. b)
			NewReg("N",(cAlias)->A1_COD,"",(cAlias)->A1_LOJA,(cAlias)->&(cPref+"_NOME"),cTipo,"S",cImpPLP,TMP->ALIQPER,"N","N",cSituaca,dDatIni,dDatFim)
			lAct := .T.
		ElseIf  cOrigen == "P"   //Prov-Ret: Punto 1. b)
			NewReg("N","",(cAlias)->A2_COD,(cAlias)->A2_LOJA,(cAlias)->&(cPref+"_NOME"),cTipo,"S",cImpRLP,TMP->ALIQRET,"N","N",cSituaca,dDatIni,dDatFim)
			lAct := .T.
		Endif
	EndIf	  
Endif 

(cTmp)->(dbCloseArea())
RestArea(aArea)
	
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³NewReg    ³Autor  ³Raúl Ortiz           ³Data  ³11/10/2018  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Crea un nuevo registro en la SFH      					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAgente - Indica si es agente o no                          ³±±
±±³          ³cCliente  - Si es cliente se informa el código 		      ³±±
±±³          ³cFornec   - Si es proveedor se informa el código	    	  ³±±
±±³          ³cLoja - Se informa la loja correspondiente Cliente/Proveedor³±±
±±³          ³cNome   - Nombre Cliente/Proveedor     					  ³±±
±±³          ³cTipo   - Tipo de contribuyente       					  ³±±
±±³          ³cPercibi   - sistema es agente recaudador (S/N)   		  ³±±
±±³          ³cImposto   - Clave del impuesto (IB2, IBP, IBR, etc.)	      ³±±
±±³          ³nAliq   - Alicuota                     					  ³±±
±±³          ³nPercent   - Porcentaje de exencion.    					  ³±±
±±³          ³cIsento   - Exento (S/N)               					  ³±±
±±³          ³cAperIb   - Agente de recaudaciones Cliente/Proveedor (S/N) ³±±
±±³          ³cSituaca - Situación del Cliente/Proveedor				  ³±±
±±³          ³dIniVige   - Fecha de inicio de vigencia					  ³±±
±±³          ³dFimVige   - Fecha de fin de vigencia 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nulo                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Fiscal - Argentina 			                  			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß /*/
Static Function NewReg(cAgente,cCliente,cFornec,cLoja,cNome,cTipo,cPercibi,cImposto,nAliq,cIsento,cAperIb,cSituaca,dIniVige,dFimVige)
Default cAgente		:= ""
Default cCliente	:= ""
Default cFornec		:= ""
Default cLoja		:= ""
Default cNome		:= ""
Default cTipo		:= ""
Default cPercibi	:= ""
Default cImposto	:= ""
Default nAliq		:= 0
Default cIsento     := ""
Default cAperIb		:= ""
Default cSituaca	:= ""
Default dIniVige	:= CTOD("//")
Default dFimVige	:= CTOD("//")

	Reclock("SFH",.T.)
	SFH->FH_FILIAL	:= xFilial("SFH")
	SFH->FH_AGENTE	:= cAgente
	SFH->FH_CLIENTE	:= cCliente
	SFH->FH_FORNECE	:= cFornec
	SFH->FH_LOJA	:= cLoja
	SFH->FH_NOME	:= cNome
	SFH->FH_TIPO	:= cTipo
	SFH->FH_PERCIBI	:= cPercibi
	SFH->FH_ZONFIS	:= "BA"
	SFH->FH_IMPOSTO	:= cImposto
	SFH->FH_ALIQ	:= nAliq
	If  nAliq  == 0
		SFH->FH_PERCENT	:= 100		
	Else
		SFH->FH_PERCENT	:= 0
	Endif
	SFH->FH_ISENTO	:= cIsento	
	SFH->FH_APERIB	:= cAperIb
	SFH->FH_SITUACA	:= cSituaca
	SFH->FH_INIVIGE	:= dIniVige
	SFH->FH_FIMVIGE	:= dFimVige
	SFH->(MsUnlock())
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³VerifImp     ³ Autor ³ TOTVS              ³ Data ³17/01/2019³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Verificar el impuesto RLP.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³GeraTemp(aArqTmp)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Especifico FISA821                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Static Function VerifImp()
Local aArea		:= getArea()
Local cTmpImp   := GetNextAlias()  
Local cQuery	:= ""
Local lRet      := .F.
	
cQuery	:= 	"SELECT FB_CODIGO " 
cQuery	+=	"FROM "
cQuery	+=		RetSqlName("SFB") + " SFB "
cQuery	+=	"WHERE "
cQuery	+=		"FB_FILIAL='"+ xFilial("SFB")+"' AND "
cQuery	+=		"FB_ESTADO  =' " +cImpRLP+ "' AND "
cQuery	+=		" FB_CLASSIF IN ('1','5','8')  AND "
//1-Ingresos Brutos, 5-Municipales, 8-IVA Importaciones   
cquery	+=		"FB_CLASSE = 'P' AND "
//P-Percepciones 
cquery	+=		"(FB_TIPO = 'P' OR  FB_TIPO = 'M') AND "
//P-Provincial, M=Municipales 
cQuery	+=		"D_E_L_E_T_=' ' "
cQuery +=   "ORDER BY FB_ESTADO"
	
cQuery := ChangeQuery(cQuery)           
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmpImp,.T.,.T.)
		 
While (cTmpImp)->(!Eof())
	lRet := .T. //Descartar los que son Aduana (A2_TIPO) porque cumplen con las caracteristicas. 
	(cTmpImp)->(dbskip())
EndDo
(cTmpImp)->(dbCloseArea())

RestArea(aArea)

Return lRet 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³NaoExiste    ³ Autor ³ TOTVS              ³ Data ³18/01/2019³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Verificar si no existe un registro exactamente igual.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Especifico FISA821                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Static Function NaoExiste(lCli,cCodigo,cLoja,cImposto,nAliq) 
Local aArea		:= GetArea()
Local cQuery	:= ""	
Local cSFH		:= InitSqlName("SFH")
Local cTmpSFH   := GetNextAlias()                                
Local lInsSFH   := .T. 
Local nCont     := 0
Default lCli    := .T.
Default cCodigo := ""
Default cLoja   := ""
Default cImposto:= ""
Default nAliq   := 0

//Seleccionar cliente o proveedor de SFH para verificar si ya existe un registro 
cQuery := "SELECT * "
cQuery += "FROM "
cQuery +=	cSFH + " SFH " 
cQuery += 	"WHERE " 
cQuery += 	"FH_FILIAL ='" + xFilial("SFH") + "' AND "
If  lCli	
	cQuery +=  	"FH_CLIENTE='" + cCodigo	  	+ "' AND "
	cQuery += 	"FH_LOJA   ='" + cLoja      	+ "' AND "
Else       
	cQuery +=  	"FH_FORNECE='" + cCodigo		+ "' AND "
	cQuery += 	"FH_LOJA   ='" + cLoja      	+ "' AND "
EndIf
cQuery += "FH_IMPOSTO='" + cImposto  +"' AND "
cQuery += "FH_INIVIGE='" + DTOS(dDatIni)	+ "' AND "
cQuery += "FH_FIMVIGE='" + DTOS(dDatFim)    + "' AND "
cQuery += "FH_ALIQ= " + Alltrim(str(nAliq)) + " AND " 

cQuery += "FH_ZONFIS  = 'BA'  AND  " 
cQuery += "D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY "
cQuery += "FH_INIVIGE DESC " 

cQuery := ChangeQuery(cQuery) 
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmpSFH,.T.,.T.)                    

Count to nCont
(cTmpSFH)->(dbGoTop())
	
If  nCont > 0 //Existe un registro exactamente igual, no debe generar registro.
	lInsSFH := .F.  
Endif
(cTmpSFH)->(dbCloseArea())

RestArea(aArea)
Return lInsSFH 
