import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'error_handler.dart';

class ErrorBanner extends StatefulWidget {
  const ErrorBanner({super.key, this.child});

  final Widget? child;

  @override
  State<ErrorBanner> createState() => _ErrorBannerState();
}

class _ErrorBannerState extends State<ErrorBanner> {
  AppError? _currentError;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    ErrorHandler.instance.addListener(_onError);
  }

  @override
  void dispose() {
    ErrorHandler.instance.removeListener(_onError);
    super.dispose();
  }

  void _onError(AppError error) {
    if (!mounted) return;
    setState(() {
      _currentError = error;
      _visible = true;
    });

    // Auto-dismiss after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => _visible = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.child != null) widget.child!,
        if (_visible && _currentError != null)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(12),
              color: _getErrorColor(context),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      _getErrorIcon(),
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_currentError!.title != null)
                            Text(
                              _currentError!.title!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          Text(
                            _currentError!.userMessage ?? _currentError!.message,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (_currentError!.suggestion != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              _currentError!.suggestion!,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 16),
                      onPressed: () => setState(() => _visible = false),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Color _getErrorColor(BuildContext context) {
    switch (_currentError?.severity) {
      case ErrorSeverity.info:
        return Colors.blue;
      case ErrorSeverity.warning:
        return Colors.orange;
      case ErrorSeverity.error:
        return Colors.red;
      case ErrorSeverity.critical:
        return Colors.red.shade900;
      default:
        return Colors.red;
    }
  }

  IconData _getErrorIcon() {
    switch (_currentError?.severity) {
      case ErrorSeverity.info:
        return Icons.info;
      case ErrorSeverity.warning:
        return Icons.warning;
      case ErrorSeverity.error:
        return Icons.error;
      case ErrorSeverity.critical:
        return Icons.error_outline;
      default:
        return Icons.error;
    }
  }
}
