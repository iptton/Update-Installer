#pragma once

#include "Platform.h"
#include "UpdateMessage.h"
#include "UpdateObserver.h"

#include "wincore.h"
#include "controls.h"
#include "stdcontrols.h"

class UpdateDialogWin32 : public UpdateObserver
{
	public:
		UpdateDialogWin32();
		~UpdateDialogWin32();

		void init();
		void exec();

		// implements UpdateObserver
		virtual void updateError(const std::string& errorMessage);
		virtual void updateProgress(int percentage);
		virtual void updateFinished();

		LRESULT WINAPI windowProc(HWND window, UINT message, WPARAM wParam, LPARAM lParam);

	private:
		void installWindowProc(CWnd* window);

		CWinApp m_app;
		CWnd m_window;
		CStatic m_progressLabel;
		CProgressBar m_progressBar;
		CButton m_finishButton;
		bool m_hadError;
};

