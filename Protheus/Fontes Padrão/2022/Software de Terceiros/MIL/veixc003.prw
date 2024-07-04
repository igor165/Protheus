// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 07     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "PROTHEUS.CH"
#Include "VEIXC003.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VEIXC003 º Autor ³ Andre Luis Almeida º Data ³  20/06/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Visualiza (F)Fotos / (V)Videos do Veiculo, por:            º±±
±±º          ³                                                            º±±
±±º          ³ >> CHAINT                                                  º±±
±±º          ³  (F) MV_DIRFTGC + "V" + CHAINT + "_*.PNG"                  º±±
±±º          ³  (F) MV_DIRFTGC + "V" + CHAINT + "_*.JPG"                  º±±
±±º          ³  (V) MV_DIRFTGC + "V" + CHAINT + "_*.MP4"                  º±±
±±º          ³  (V) MV_DIRFTGC + "V" + CHAINT + "_*.WMV"                  º±±
±±º          ³  (V) MV_DIRFTGC + "V" + CHAINT + "_*.AVI"                  º±±
±±º          ³                                                            º±±
±±º          ³ >> MARCA + MODELO                                          º±±
±±º          ³  (F) MV_DIRFTGC + "V" + MARCA + MODELO + "_*.PNG"          º±±
±±º          ³  (F) MV_DIRFTGC + "V" + MARCA + MODELO + "_*.JPG"          º±±
±±º          ³  (V) MV_DIRFTGC + "V" + MARCA + MODELO + "_*.MP4"          º±±
±±º          ³  (V) MV_DIRFTGC + "V" + MARCA + MODELO + "_*.WMV"          º±±
±±º          ³  (V) MV_DIRFTGC + "V" + MARCA + MODELO + "_*.AVI"          º±±
±±º          ³                                                            º±±
±±º          ³ >> MARCA + GRUPO DO MODELO                                 º±±
±±º          ³  (F) MV_DIRFTGC + "V" + MARCA + GRUPO MODELO + "_*.PNG"    º±±
±±º          ³  (F) MV_DIRFTGC + "V" + MARCA + GRUPO MODELO + "_*.JPG"    º±±
±±º          ³  (V) MV_DIRFTGC + "V" + MARCA + GRUPO MODELO + "_*.MP4"    º±±
±±º          ³  (V) MV_DIRFTGC + "V" + MARCA + GRUPO MODELO + "_*.WMV"    º±±
±±º          ³  (V) MV_DIRFTGC + "V" + MARCA + GRUPO MODELO + "_*.AVI"    º±±
±±º          ³                                                            º±±
±±º          ³ >> MARCA                                                   º±±
±±º          ³  (F) MV_DIRFTGC + "V" + MARCA + "_*.PNG"                   º±±
±±º          ³  (F) MV_DIRFTGC + "V" + MARCA + "_*.JPG"                   º±±
±±º          ³  (V) MV_DIRFTGC + "V" + MARCA + "_*.MP4"                   º±±
±±º          ³  (V) MV_DIRFTGC + "V" + MARCA + "_*.WMV"                   º±±
±±º          ³  (V) MV_DIRFTGC + "V" + MARCA + "_*.AVI"                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º  TAMANHO PADRAO DAS FOTOS  -->  560pix (largura)  x  530pix (altura)  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cChaInt = Chassi Interno do Veiculo                        º±±
±±º          ³ cCodMar = Marca do Veiculo                                 º±±
±±º          ³ cModVei = Modelo do Veiculo                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Veiculos                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIXC003(cChaInt,cCodMar,cModVei)
Local nCol       := 0
Local nLin       := 0
Local aFotosPNG  := {} // Todas as fotos PNG
Local aFotosJPG  := {} // Todas as fotos JPG
Local aVideosMP4 := {} // Todos os videos MP4
Local aVideosWMV := {} // Todos os videos WMV
Local aVideosAVI := {} // Todos os videos AVI
Local cDirFotVid := GetNewPar("MV_DIRFTGC","") // Diretorio das FOTOS e VIDEOS
Local nCntFor    := 0
Local cChassi    := ""
Local aTitFoto   := {}
Private aFotos   := {}
Private aVideos  := {}
Default cCodMar  := ""
Default cModVei  := ""

If FindFunction("IsHtml") .and. IsHtml() // Esta utilizando SmartClient HTML
    MsgStop(STR0004,STR0002) // Opcao nao disponivel para SmartClient HTML! / Atencao
	Return()
EndIf

If !Empty(cChaInt)
	VV1->(DbSetOrder(1))
	VV1->(DbSeek(xFilial("VV1")+cChaInt))
	cCodMar := VV1->VV1_CODMAR
	cModVei := VV1->VV1_MODVEI
	cChassi := Alltrim(VV1->VV1_CHASSI)+" - "
EndIf
VV2->(dbSetOrder(1))
VV2->(dbSeek(xFilial("VV2")+cCodMar+cModVei))

///////////////////////////////////////////////////
// Levanta FOTOS do CHAINT - Veiculo especifico  //
///////////////////////////////////////////////////
ADir(cDirFotVid+"V"+cChaInt+"_*.png",aFotosPNG)
ADir(cDirFotVid+"V"+cChaInt+"_*.jpg",aFotosJPG)

// Caso nao exista fotos pelo CHAINT
If len(aFotosPNG) <= 0 .and. len(aFotosJPG) <= 0 

	//////////////////////////////////////////////////
	// Levanta FOTOS da MARCA + MODELO	            //
	//////////////////////////////////////////////////
	ADir(cDirFotVid+"V"+Alltrim(cCodMar)+Alltrim(cModVei)+"_*.png",aFotosPNG)
	ADir(cDirFotVid+"V"+Alltrim(cCodMar)+Alltrim(cModVei)+"_*.jpg",aFotosJPG)

	// Caso nao exista fotos pela MARCA + MODELO
	If len(aFotosPNG) <= 0 .and. len(aFotosJPG) <= 0

		//////////////////////////////////////////////////
		// Levanta FOTOS da MARCA + GRUPO DO MODELO     //
		//////////////////////////////////////////////////
		ADir(cDirFotVid+"V"+Alltrim(cCodMar)+Alltrim(VV2->VV2_GRUMOD)+"_*.png",aFotosPNG)
		ADir(cDirFotVid+"V"+Alltrim(cCodMar)+Alltrim(VV2->VV2_GRUMOD)+"_*.jpg",aFotosJPG)

		// Caso nao exista fotos pela MARCA + GRUPO DO MODELO
		If len(aFotosPNG) <= 0 .and. len(aFotosJPG) <= 0

			//////////////////////////////////////////////////
			// Levanta FOTOS da MARCA                       //
			//////////////////////////////////////////////////
			ADir(cDirFotVid+"V"+Alltrim(cCodMar)+"_*.png",aFotosPNG)
			ADir(cDirFotVid+"V"+Alltrim(cCodMar)+"_*.jpg",aFotosJPG)

		EndIf

	EndIf

EndIf

///////////////////////////////////////////////////
// Levanta VIDEOS do CHAINT - Veiculo especifico //
///////////////////////////////////////////////////
ADir(cDirFotVid+"V"+cChaInt+"_*.mp4",aVideosMP4)
ADir(cDirFotVid+"V"+cChaInt+"_*.wmv",aVideosWMV)
ADir(cDirFotVid+"V"+cChaInt+"_*.avi",aVideosAVI)

// Caso nao exista Videos pelo CHAINT
If len(aVideosMP4) <= 0 .and. len(aVideosWMV) <= 0 .and. len(aVideosAVI) <= 0

	//////////////////////////////////////////////////
	// Levanta VIDEOS da MARCA + MODELO	            //
	//////////////////////////////////////////////////
	ADir(cDirFotVid+"V"+Alltrim(cCodMar)+Alltrim(cModVei)+"_*.mp4",aVideosMP4)
	ADir(cDirFotVid+"V"+Alltrim(cCodMar)+Alltrim(cModVei)+"_*.wmv",aVideosWMV)
	ADir(cDirFotVid+"V"+Alltrim(cCodMar)+Alltrim(cModVei)+"_*.avi",aVideosAVI)

	// Caso nao exista Videos pela MARCA + MODELO
	If len(aVideosMP4) <= 0 .and. len(aVideosWMV) <= 0 .and. len(aVideosAVI) <= 0

		//////////////////////////////////////////////////
		// Levanta VIDEOS da MARCA + GRUPO DO MODELO    //
		//////////////////////////////////////////////////
		ADir(cDirFotVid+"V"+Alltrim(cCodMar)+Alltrim(VV2->VV2_GRUMOD)+"_*.mp4",aVideosMP4)
		ADir(cDirFotVid+"V"+Alltrim(cCodMar)+Alltrim(VV2->VV2_GRUMOD)+"_*.wmv",aVideosWMV)
		ADir(cDirFotVid+"V"+Alltrim(cCodMar)+Alltrim(VV2->VV2_GRUMOD)+"_*.avi",aVideosAVI)

		// Caso nao exista Videos pela MARCA + GRUPO DO MODELO
		If len(aVideosMP4) <= 0 .and. len(aVideosWMV) <= 0 .and. len(aVideosAVI) <= 0

			//////////////////////////////////////////////////
			// Levanta VIDEOS da MARCA                      //
			//////////////////////////////////////////////////
			ADir(cDirFotVid+"V"+Alltrim(cCodMar)+"_*.mp4",aVideosMP4)
			ADir(cDirFotVid+"V"+Alltrim(cCodMar)+"_*.wmv",aVideosWMV)
			ADir(cDirFotVid+"V"+Alltrim(cCodMar)+"_*.avi",aVideosAVI)

		EndIf

	EndIf

EndIf

If ExistBlock("VXC03LEV")
	ExecBlock("VXC03LEV ", .f., .f., { aFotos, aVideos, cCodMar, cModVei, cChassi, cChaInt })
EndIf

If len(aFotosPNG) <= 0 .and. len(aFotosJPG) <= 0 .and. len(aVideosMP4) <= 0 .and. len(aVideosWMV) <= 0 .and. len(aVideosAVI) <= 0 .and. len(aVideos) <= 0 .and. len(aFotos) <= 0
	MsgStop(STR0003+CHR(13)+CHR(10)+CHR(13)+CHR(10)+IIf(!Empty(cDirFotVid),cDirFotVid,"MV_DIRFTGC"),STR0002) // Foto(s)/Video(s) do Veiculo nao encontrados! / Atencao
	Return
Else
	For nCntFor := 1 to len(aFotosPNG)
		aAdd(aFotos,cDirFotVid+aFotosPNG[nCntFor]) // Foto PNG
	Next
	For nCntFor := 1 to len(aFotosJPG)
		aAdd(aFotos,cDirFotVid+aFotosJPG[nCntFor]) // Foto JPG
	Next
	// adicionando titulos das fotos
	for nCntFor := 1 to Len(aFotos)
		aAdd(aTitFoto, "< " + ALLTRIM(STR(nCntFor)) + " >")
	next
	If len(aVideosMP4) > 0 .or. len(aVideosWMV) > 0 .or. len(aVideosAVI) > 0
		aAdd(aTitFoto,"< "+STR0005+" >") // Videos
		For nCntFor := 1 to len(aVideosMP4)
			aAdd(aVideos,cDirFotVid+aVideosMP4[nCntFor]) // Video MP4
		Next
		For nCntFor := 1 to len(aVideosWMV)
			aAdd(aVideos,cDirFotVid+aVideosWMV[nCntFor]) // Video WMV
		Next
		For nCntFor := 1 to len(aVideosAVI)
			aAdd(aVideos,cDirFotVid+aVideosAVI[nCntFor]) // Video AVI
		Next
	EndIf
EndIf

If len(aFotos) > 0 .or. len(aVideos) > 0
	DEFINE MSDIALOG oFotoVeic TITLE (STR0001+": "+cChassi+Alltrim(cCodMar)+" "+Alltrim(VV2->VV2_DESMOD)) From 00,00 to 560,560 PIXEL of oMainWnd  // Foto(s)/Video(s) do Veiculo
		@ 000,000 BUTTON oSair PROMPT "" OF oFotoVeic SIZE 1,1 PIXEL ACTION oFotoVeic:End()
		//
		oFoldFoto := TFolder():New(0,8,aTitFoto,{}, oFotoVeic,,,,.t.,.f.,280,280)
		oFoldFoto:Align := CONTROL_ALIGN_ALLCLIENT 
		/////////////////////////////////////////////////////////////////////////
		// TAMANHO PADRAO DA IMAGEM  -->  560pix (largura)  x  530pix (altura) //
		/////////////////////////////////////////////////////////////////////////
		For nCntFor := 1 to len(aFotos)
			&("oBitMap"+Alltrim(str(nCntFor))) := TBitmap():New(000,000,280,280,,aFotos[nCntFor],.T.,oFoldFoto:aDialogs[nCntFor],,,.T.,.F.,,,.F.,,.T.,,.F.)
 	        &("oBitMap"+Alltrim(str(nCntFor))+":Align") := CONTROL_ALIGN_ALLCLIENT
 		Next
		nCol := 0
		nLin := 0
		For nCntFor := 1 to len(aVideos)
			nCol++
			If nCol > 4
				nCol := 1
				nLin += 12
			EndIf
			&("oMedia"+Alltrim(str(nCntFor))) := TButton():New( nLin + 2 /* <nRow> */, ( nCol * 70 ) - 69 /* <nCol> */, (STR0006+" "+Alltrim(str(nCntFor))) /* <cCaption> */, oFoldFoto:aDialogs[len(aFotos)+1] /* <oWnd> */,;
													&('{ || ' + "WinExec( 'cmd /c "+aVideos[nCntFor]+"' )" + ' }')	/* <{uAction}> */, 68 /* <nWidth> */, 10 /* <nHeight> */, /* <nHelpId> */, /* <oFont> */, /* <.default.> */,;
													.t.	/* <.pixel.> */, /* <.design.> */, /* <cMsg> */, /* <.update.> */, /* <{WhenFunc}> */,/* <{uValid}> */, /* <.lCancel.> */	)
   	  	Next
	ACTIVATE MSDIALOG oFotoVeic CENTER
EndIf
Return()