import 'package:flutter/material.dart';
import 'dart:async';

class ProcessingLoadingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  
  const ProcessingLoadingScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<ProcessingLoadingScreen> createState() => _ProcessingLoadingScreenState();
}

class _ProcessingLoadingScreenState extends State<ProcessingLoadingScreen> with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _controller;
  late Animation<double> _animation;
  
  final List<String> _steps = [
    'Görüntü yükleniyor...',
    'Arka plan kaldırılıyor...',
    'Yaprak özellikleri analiz ediliyor...',
    'AI modeli çalışıyor...',
    'Hastalık tespiti yapılıyor...',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    _startProcessing();
  }

  void _startProcessing() async {
    // Her adım için 1600ms bekle (2x daha uzun)
    for (int i = 0; i < _steps.length; i++) {
      if (mounted) {
        setState(() {
          _currentStep = i;
        });
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
    
    // Son adımda biraz daha bekle
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (mounted) {
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated plant icon
              ScaleTransition(
                scale: _animation,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.eco,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Progress indicator
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  value: (_currentStep + 1) / _steps.length,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Current step text
              Text(
                _steps[_currentStep],
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              // Step counter
              Text(
                '${_currentStep + 1}/${_steps.length}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              
              const SizedBox(height: 48),
              
              // All steps list
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(_steps.length, (index) {
                    final isCompleted = index < _currentStep;
                    final isCurrent = index == _currentStep;
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          // Step icon
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? theme.colorScheme.primary
                                  : isCurrent
                                      ? theme.colorScheme.primary.withOpacity(0.3)
                                      : theme.colorScheme.surface,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.colorScheme.primary.withOpacity(
                                  isCompleted || isCurrent ? 1.0 : 0.3,
                                ),
                                width: 2,
                              ),
                            ),
                            child: isCompleted
                                ? Icon(
                                    Icons.check,
                                    size: 14,
                                    color: theme.colorScheme.onPrimary,
                                  )
                                : isCurrent
                                    ? Center(
                                        child: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      )
                                    : null,
                          ),
                          
                          const SizedBox(width: 12),
                          
                          // Step text
                          Expanded(
                            child: Text(
                              _steps[index],
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isCompleted || isCurrent
                                    ? theme.colorScheme.onSurface
                                    : theme.colorScheme.onSurface.withOpacity(0.4),
                                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
